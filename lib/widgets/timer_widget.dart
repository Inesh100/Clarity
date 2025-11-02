import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class StudyTimer extends StatefulWidget {
  final Function(bool success) onComplete;

  const StudyTimer({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<StudyTimer> createState() => _StudyTimerState();
}

class _StudyTimerState extends State<StudyTimer> {
  final CountDownController _controller = CountDownController();

  int _selectedMinutes = 25;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _ignoreOnComplete = false;
  bool _dialogOpen = false;

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _ignoreOnComplete = false;
    });

    // Delay start slightly to ensure controller is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  void _pauseOrResume() {
    setState(() {
      if (_isPaused) {
        _controller.resume();
        _isPaused = false;
      } else {
        _controller.pause();
        _isPaused = true;
      }
    });
  }

  void _resetTimer() {
    _ignoreOnComplete = true;
    try {
      _controller.pause();
      _controller.reset();
    } catch (_) {}

    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _ignoreOnComplete = false;
    });
  }

  Future<void> _showCompletionDialog() async {
    if (_ignoreOnComplete || _dialogOpen) return;
    _dialogOpen = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time’s up!"),
        content: const Text("Were you able to complete your task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Not yet"),
          ),
        ],
      ),
    );

    widget.onComplete(result ?? false);
    _dialogOpen = false;
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _selectedMinutes * 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isRunning)
          Column(
            children: [
              Text("Set Study Duration",
                  style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _selectedMinutes.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                label: "$_selectedMinutes min",
                onChanged: (value) {
                  setState(() => _selectedMinutes = value.toInt());
                },
              ),
            ],
          ),
        const SizedBox(height: 20),

        // ✅ Countdown circle
        CircularCountDownTimer(
          duration: totalSeconds,
          controller: _controller,
          width: 180,
          height: 180,
          ringColor: Colors.grey.shade300,
          fillColor: Colors.indigoAccent,
          backgroundColor: Colors.indigo.withOpacity(0.1),
          strokeWidth: 12.0,
          strokeCap: StrokeCap.round,
          textStyle: const TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
          isReverse: true,
          isTimerTextShown: true,
          autoStart: false, // prevent auto start
          onComplete: _showCompletionDialog,
        ),
        const SizedBox(height: 25),

        if (!_isRunning)
          ElevatedButton.icon(
            onPressed: _startTimer,
            icon: const Icon(Icons.play_arrow),
            label: const Text("Start"),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pauseOrResume,
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(_isPaused ? "Resume" : "Pause"),
              ),
              const SizedBox(width: 15),
              ElevatedButton.icon(
                onPressed: _resetTimer,
                icon: const Icon(Icons.stop),
                label: const Text("Reset"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
              ),
            ],
          ),
      ],
    );
  }
}
