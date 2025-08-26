import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../widgets/score_badge.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  final Player player;

  const GameScreen({super.key, required this.player});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double posX = 100;
  double posY = 100;
  int score = 0;
  int highScore = 0;
  int timeLeft = 30;
  Timer? gameTimer;
  Timer? dotTimer;
  bool gameOver = false;
  Random random = Random();
  double topSectionHeight = 0;
  int dotSpeed = 800; // Initial speed in milliseconds
  final int minDotSpeed = 300; // Minimum speed limit

  final GlobalKey _topSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = _topSectionKey.currentContext?.findRenderObject() as RenderBox;
      setState(() {
        topSectionHeight = renderBox.size.height + 24;
      });
      _startGame();
    });
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
  }

  void _startGame() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        _endGame();
      }
    });

    _startDotTimer();
  }

  void _startDotTimer() {
    dotTimer?.cancel();
    dotTimer = Timer.periodic(Duration(milliseconds: dotSpeed), (_) {
      _moveDot();
    });
  }

  void _moveDot() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    setState(() {
      posX = random.nextDouble() * (screenWidth - 60);
      posY = topSectionHeight + random.nextDouble() * (screenHeight - topSectionHeight - bottomPadding - 60);
    });
  }

  void _onDotTap() {
    setState(() {
      score++;

      if (dotSpeed > minDotSpeed) {
        dotSpeed -= 20;
        _startDotTimer();
      }

      _moveDot();
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    dotTimer?.cancel();

    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      _saveHighScore();
    }

    setState(() {
      gameOver = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Game Over', style: TextStyle(color: Colors.white)),
        content: Text('Your Score: $score',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGradientEnd,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: posX,
              top: posY,
              child: GestureDetector(
                onTap: _onDotTap,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dotColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dotColor.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 24,
              left: 20,
              right: 20,
              child: Container(
                key: _topSectionKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(widget.player.avatar),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.player.name,
                          style: AppTextStyles.subtitle.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ScoreBadge(label: 'Score', value: score.toString()),
                        ScoreBadge(label: 'High Score', value: highScore.toString()),
                        ScoreBadge(label: 'Time', value: '$timeLeft s'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
