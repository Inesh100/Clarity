import 'package:flutter/material.dart';
import '../data/quotes.dart';
import '../widgets/timer_widget.dart';
import '../styles/app_text.dart';
import '../styles/app_colors.dart';

class MotivationTimerPage extends StatefulWidget {
  const MotivationTimerPage({Key? key}) : super(key: key);

  @override
  _MotivationTimerPageState createState() => _MotivationTimerPageState();
}

class _MotivationTimerPageState extends State<MotivationTimerPage> {
  String currentQuote = "";

  @override
  void initState() {
    super.initState();
    _getRandomGeneralQuote();
  }

  void _getRandomGeneralQuote() {
    setState(() {
      currentQuote = getRandomGeneralQuote();
    });
  }

  void _handleTimerComplete(bool success) {
    setState(() {
      currentQuote = success
          ? getRandomSuccessQuote()
          : getRandomFailureQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Focus & Motivation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    currentQuote,
                    key: ValueKey(currentQuote),
                    style: AppTextStyles.heading2.copyWith(fontStyle: FontStyle.italic, height: 1.4, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                StudyTimer(onComplete: _handleTimerComplete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
