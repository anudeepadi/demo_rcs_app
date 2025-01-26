import 'dart:async';
import 'dart:math' as math;

class VoiceRecorderService {
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  List<double> _waveformData = [];
  final int _waveformSampleRate = 50; // ms between samples
  final int _maxAmplitude = 100;

  int get recordingDuration => _recordingDuration;
  String get waveform => _waveformData.join(',');

  void startRecording() {
    _recordingDuration = 0;
    _waveformData = [];

    // Simulate recording and waveform generation
    _recordingTimer = Timer.periodic(Duration(milliseconds: _waveformSampleRate), (timer) {
      _recordingDuration += _waveformSampleRate;
      
      // Generate random amplitude for visualization
      final amplitude = math.Random().nextDouble() * _maxAmplitude;
      _waveformData.add(amplitude / _maxAmplitude);
    });
  }

  Future<RecordingResult> stopRecording() async {
    _recordingTimer?.cancel();
    
    // Simulate saving the audio file
    await Future.delayed(const Duration(milliseconds: 500));
    
    return RecordingResult(
      duration: _recordingDuration,
      waveform: waveform,
      filePath: 'simulated_voice_message.m4a',
    );
  }

  void cancelRecording() {
    _recordingTimer?.cancel();
    _recordingDuration = 0;
    _waveformData = [];
  }
}

class RecordingResult {
  final int duration;
  final String waveform;
  final String filePath;

  RecordingResult({
    required this.duration,
    required this.waveform,
    required this.filePath,
  });
}