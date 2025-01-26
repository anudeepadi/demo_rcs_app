import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/bot_chat_provider.dart';
import 'providers/channel_provider.dart';
import 'providers/system_chat_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => BotChatProvider()),
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
        ChangeNotifierProvider(create: (_) => SystemChatProvider()),
      ],
      child: MaterialApp(
        title: 'RCS Demo App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}