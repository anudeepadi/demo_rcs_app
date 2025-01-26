from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict
import json
import asyncio
from datetime import datetime
import aiofiles
import os
import yt_dlp

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, websocket: WebSocket, client_id: str):
        await websocket.accept()
        self.active_connections[client_id] = websocket

    def disconnect(self, client_id: str):
        if client_id in self.active_connections:
            del self.active_connections[client_id]

    async def broadcast(self, message: dict):
        for connection in self.active_connections.values():
            await connection.send_json(message)

    async def send_personal_message(self, message: dict, client_id: str):
        if client_id in self.active_connections:
            await self.active_connections[client_id].send_json(message)

manager = ConnectionManager()

# Video handling
async def process_youtube_link(url: str) -> dict:
    try:
        ydl_opts = {
            'format': 'best[height<=480]',
            'extract_flat': True,
        }
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            return {
                'title': info.get('title', ''),
                'thumbnail': info.get('thumbnail', ''),
                'duration': info.get('duration', 0),
                'view_count': info.get('view_count', 0),
                'video_url': info.get('url', '')
            }
    except Exception as e:
        print(f"Error processing YouTube link: {e}")
        return {}

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    await manager.connect(websocket, client_id)
    try:
        while True:
            data = await websocket.receive_text()
            message = json.loads(data)
            
            # Handle different message types
            if message.get('type') == 'message':
                # Check for YouTube links
                content = message.get('content', '')
                if 'youtube.com' in content or 'youtu.be' in content:
                    video_info = await process_youtube_link(content)
                    if video_info:
                        await manager.broadcast({
                            'type': 'video_preview',
                            'client_id': client_id,
                            'content': content,
                            'video_info': video_info,
                            'timestamp': datetime.now().isoformat()
                        })
                else:
                    await manager.broadcast({
                        'type': 'message',
                        'client_id': client_id,
                        'content': content,
                        'timestamp': datetime.now().isoformat()
                    })
            
            elif message.get('type') == 'typing':
                await manager.broadcast({
                    'type': 'typing',
                    'client_id': client_id,
                    'is_typing': message.get('is_typing', False)
                })

    except WebSocketDisconnect:
        manager.disconnect(client_id)
        await manager.broadcast({
            'type': 'system',
            'content': f'Client #{client_id} left the chat'
        })

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)