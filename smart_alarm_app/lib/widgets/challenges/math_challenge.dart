import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/enums.dart';

class MathChallenge extends StatefulWidget {
  final ChallengeDifficulty difficulty;
  final Map<String, dynamic>? config;
  final VoidCallback onSuccess;

  const MathChallenge({
    super.key,
    required this.difficulty,
    this.config,
    required this.onSuccess,
  });

  @override
  State<MathChallenge> createState() => _MathChallengeState();
}

class _MathChallengeState extends State<MathChallenge> {
  final _answerController = TextEditingController();
  final _random = Random();
  
  late int _num1;
  late int _num2;
  late String _operator;
  late int _correctAnswer;
  late int _problemsCompleted;
  late int _requiredProblems;
  
  String _errorMessage = '';
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _requiredProblems = _getRequiredProblems();
    _problemsCompleted = 0;
    _generateProblem();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  int _getRequiredProblems() {
    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        return 1;
      case ChallengeDifficulty.medium:
        return 2;
      case ChallengeDifficulty.hard:
        return 3;
    }
  }

  void _generateProblem() {
    setState(() {
      _errorMessage = '';
      _isCorrect = false;
      _answerController.clear();
    });

    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        _generateEasyProblem();
        break;
      case ChallengeDifficulty.medium:
        _generateMediumProblem();
        break;
      case ChallengeDifficulty.hard:
        _generateHardProblem();
        break;
    }
  }

  void _generateEasyProblem() {
    // Single digit addition and subtraction
    _num1 = _random.nextInt(9) + 1; // 1-9
    _num2 = _random.nextInt(9) + 1; // 1-9
    
    if (_random.nextBool()) {
      _operator = '+';
      _correctAnswer = _num1 + _num2;
    } else {
      _operator = '-';
      // Make sure result is positive
      if (_num1 < _num2) {
        final temp = _num1;
        _num1 = _num2;
        _num2 = temp;
      }
      _correctAnswer = _num1 - _num2;
    }
  }

  void _generateMediumProblem() {
    // Two digit numbers with addition, subtraction, multiplication
    final operations = ['+', '-', '×'];
    _operator = operations[_random.nextInt(operations.length)];
    
    switch (_operator) {
      case '+':
        _num1 = _random.nextInt(90) + 10; // 10-99
        _num2 = _random.nextInt(90) + 10; // 10-99
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
        _num1 = _random.nextInt(90) + 10; // 10-99
        _num2 = _random.nextInt(_num1); // Ensure positive result
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _num1 = _random.nextInt(9) + 2; // 2-10
        _num2 = _random.nextInt(9) + 2; // 2-10
        _correctAnswer = _num1 * _num2;
        break;
    }
  }

  void _generateHardProblem() {
    // Three digit numbers, all operations including division
    final operations = ['+', '-', '×', '÷'];
    _operator = operations[_random.nextInt(operations.length)];
    
    switch (_operator) {
      case '+':
        _num1 = _random.nextInt(900) + 100; // 100-999
        _num2 = _random.nextInt(900) + 100; // 100-999
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
        _num1 = _random.nextInt(900) + 100; // 100-999
        _num2 = _random.nextInt(_num1); // Ensure positive result
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _num1 = _random.nextInt(90) + 10; // 10-99
        _num2 = _random.nextInt(9) + 2; // 2-10
        _correctAnswer = _num1 * _num2;
        break;
      case '÷':
        // Ensure clean division
        _num2 = _random.nextInt(9) + 2; // 2-10
        _correctAnswer = _random.nextInt(90) + 10; // 10-99
        _num1 = _correctAnswer * _num2;
        break;
    }
  }

  void _checkAnswer() {
    final input = _answerController.text.trim();
    
    if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an answer';
      });
      return;
    }

    final userAnswer = int.tryParse(input);
    
    if (userAnswer == null) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    if (userAnswer == _correctAnswer) {
      setState(() {
        _isCorrect = true;
        _errorMessage = '';
        _problemsCompleted++;
      });

      // Check if all problems are completed
      if (_problemsCompleted >= _requiredProblems) {
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.onSuccess();
        });
      } else {
        // Generate next problem
        Future.delayed(const Duration(milliseconds: 800), () {
          _generateProblem();
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect! Try again.';
        _answerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress indicator
          if (_requiredProblems > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_requiredProblems, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index < _problemsCompleted
                          ? Colors.green
                          : index == _problemsCompleted
                              ? const Color(0xFF6366F1)
                              : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          // Problem display
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isCorrect 
                    ? Colors.green 
                    : _errorMessage.isNotEmpty 
                        ? Colors.red.shade300 
                        : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Problem ${_problemsCompleted + 1} of $_requiredProblems',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$_num1',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      _operator,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '$_num2',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Answer input
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '?',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 36,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
          ),

          const SizedBox(height: 16),

          // Error or success message
          SizedBox(
            height: 30,
            child: _isCorrect
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        _problemsCompleted >= _requiredProblems
                            ? 'All correct! Dismissing alarm...'
                            : 'Correct! Next problem...',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : _errorMessage.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
          ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Submit Answer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
