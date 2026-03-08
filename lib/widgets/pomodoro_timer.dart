import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';

class PomodoroTimerWidget extends StatefulWidget {
  final PomodoroSession pomodoro;
  final ValueChanged<PomodoroSession> onUpdate;

  const PomodoroTimerWidget({
    super.key,
    required this.pomodoro,
    required this.onUpdate,
  });

  @override
  State<PomodoroTimerWidget> createState() => _PomodoroTimerWidgetState();
}

class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget> {
  Timer? _timer;
  late PomodoroSession _session;

  @override
  void initState() {
    super.initState();
    _session = widget.pomodoro;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _session.isRunning = true;
    _session.startedAt ??= DateTime.now().toIso8601String();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _session.elapsedSeconds++;
        if (_session.remainingSeconds <= 0) {
          _stop();
          _showFinishedAlert();
        }
      });
      widget.onUpdate(_session);
    });
    setState(() {});
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _session.isRunning = false;
    widget.onUpdate(_session);
    setState(() {});
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _session
      ..isRunning = false
      ..elapsedSeconds = 0
      ..startedAt = null;
    widget.onUpdate(_session);
    setState(() {});
  }

  void _showFinishedAlert() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pomodoro finalizado! Hora de uma pausa.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final min = totalSeconds ~/ 60;
    final sec = totalSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _session.remainingSeconds;
    final total = _session.workMinutes * 60;
    final progress = total > 0 ? (total - remaining) / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 20),
            const SizedBox(width: 8),
            Text(
              _formatTime(remaining),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_session.isRunning)
              IconButton.filled(
                onPressed: remaining > 0 ? _start : null,
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Iniciar',
              )
            else
              IconButton.filled(
                onPressed: _stop,
                icon: const Icon(Icons.pause),
                tooltip: 'Pausar',
              ),
            const SizedBox(width: 8),
            IconButton.outlined(
              onPressed: _reset,
              icon: const Icon(Icons.replay),
              tooltip: 'Reiniciar',
            ),
          ],
        ),
      ],
    );
  }
}
