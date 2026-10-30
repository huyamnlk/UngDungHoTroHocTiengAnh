import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/word_model.dart';
import '../../widgets/custom_button.dart';

class MatchingItem {
  final int wordId;
  final String text;
  final bool isEnglish;
  bool isMatched;
  bool isSelected;

  MatchingItem({
    required this.wordId,
    required this.text,
    required this.isEnglish,
    this.isMatched = false,
    this.isSelected = false,
  });
}

class MatchingGameScreen extends StatefulWidget {
  final List<WordModel> words;

  const MatchingGameScreen({super.key, required this.words});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late List<MatchingItem> _items;
  MatchingItem? _firstSelected;
  MatchingItem? _secondSelected;
  int _moves = 0;
  int _matchedPairs = 0;
  late int _totalPairs;
  bool _isProcessing = false;
  late Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final list = List<WordModel>.from(widget.words)..shuffle();
    final selectedWords = list.take(6).toList();
    _totalPairs = selectedWords.length;
    _matchedPairs = 0;
    _moves = 0;
    _firstSelected = null;
    _secondSelected = null;
    _isProcessing = false;

    _items = [];
    for (final w in selectedWords) {
      _items.add(MatchingItem(wordId: w.id, text: w.term, isEnglish: true));
      _items.add(MatchingItem(wordId: w.id, text: w.meaning, isEnglish: false));
    }
    _items.shuffle();

    _stopwatch = Stopwatch()..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _onItemTap(MatchingItem item) {
    if (item.isMatched || item.isSelected || _isProcessing) return;

    setState(() {
      item.isSelected = true;
    });

    if (_firstSelected == null) {
      _firstSelected = item;
    } else {
      _secondSelected = item;
      _moves++;
      _isProcessing = true;

      // Kiểm tra ghép đôi
      if (_firstSelected!.wordId == _secondSelected!.wordId &&
          _firstSelected!.isEnglish != _secondSelected!.isEnglish) {
        // Ghép đúng
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() {
            _firstSelected!.isMatched = true;
            _secondSelected!.isMatched = true;
            _firstSelected!.isSelected = false;
            _secondSelected!.isSelected = false;
            _firstSelected = null;
            _secondSelected = null;
            _matchedPairs++;
            _isProcessing = false;
            if (_matchedPairs == _totalPairs) {
              _stopwatch.stop();
              _timer?.cancel();
            }
          });
        });
      } else {
        // Ghép sai -> Đổi lại sau 600ms
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _firstSelected!.isSelected = false;
            _secondSelected!.isSelected = false;
            _firstSelected = null;
            _secondSelected = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGameOver = _matchedPairs == _totalPairs;
    final seconds = _stopwatch.elapsed.inSeconds;
    final timeStr = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Ghép từ & Nghĩa'),
        backgroundColor: context.cardBg,
        elevation: 0,
        foregroundColor: context.textPrimaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Thanh thông số
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric('Thời gian', timeStr, Icons.timer_outlined, AppColors.primary),
                    _buildMetric('Số bước đi', '$_moves', Icons.touch_app_outlined, AppColors.accent),
                    _buildMetric('Đã ghép', '$_matchedPairs/$_totalPairs', Icons.check_circle_outline, AppColors.success),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bàn cờ thẻ
              Expanded(
                child: isGameOver
                    ? _buildVictoryCard(timeStr)
                    : GridView.builder(
                        itemCount: _items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.8,
                        ),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildCardItem(item);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildCardItem(MatchingItem item) {
    Color bgColor = context.cardBg;
    Color borderColor = context.borderCol;
    Color textColor = context.textPrimaryColor;

    if (item.isMatched) {
      bgColor = context.isDark ? AppColors.success.withValues(alpha: 0.2) : AppColors.successLight;
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else if (item.isSelected) {
      bgColor = context.primaryContainerCol;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    }

    return InkWell(
      onTap: () => _onItemTap(item),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: item.isSelected || item.isMatched ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          item.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: item.isEnglish ? 15 : 13,
            fontWeight: item.isEnglish ? FontWeight.bold : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryCard(String timeStr) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              'Xuất sắc!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn đã ghép đúng tất cả các từ trong $timeStr với $_moves lượt chọn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Chơi lại ván mới',
              icon: Icons.refresh_rounded,
              onPressed: () {
                setState(() {
                  _initGame();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
