import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../resource/app_colors.dart';
import 'caro_controller.dart';

class CaroView extends StatefulWidget {
  CaroView({super.key}) {
    if (!Get.isRegistered<CaroController>()) {
      Get.put(CaroController());
    }
  }

  @override
  State<CaroView> createState() => _CaroViewState();
}

class _CaroViewState extends State<CaroView> with TickerProviderStateMixin {
  final controller = Get.find<CaroController>();

  // Win line animation
  late AnimationController _lineAnim;
  late Animation<double>    _lineProg;
  bool _lineStarted = false;

  // Confetti
  late ConfettiController _confettiCtrl;

  // Board zoom — mặc định 2x
  final _transformCtrl = TransformationController();
  bool _zoomInitialized = false;

  @override
  void initState() {
    super.initState();
    _lineAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lineProg = CurvedAnimation(parent: _lineAnim, curve: Curves.easeOut);
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _lineAnim.dispose();
    _confettiCtrl.dispose();
    _transformCtrl.dispose();
    Get.delete<CaroController>();
    super.dispose();
  }

  /// Gọi sau mỗi rebuild để quản lý animation lifecycle.
  void _syncAnimations(CaroController c) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final won = c.gameOver && !c.isDraw && c.winningCells.isNotEmpty;
      if (won && !_lineStarted) {
        _lineStarted = true;
        _lineAnim.forward(from: 0);
        _confettiCtrl.play();
      } else if (!c.gameOver && _lineStarted) {
        _lineStarted = false;
        _lineAnim.reset();
        _confettiCtrl.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Caro Game',
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: GetBuilder<CaroController>(
        builder: (c) {
          _syncAnimations(c);
          // Dùng Stack để overlay confetti lên UI chính.
          // Positioned.fill đảm bảo Column nhận bounded constraints → Expanded hoạt động đúng.
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── UI chính ──
              Column(
                children: [
                  _buildTopBar(c),
                  Expanded(child: _buildBoard(c)),
                ],
              ),
              // ── Confetti overlay (pointer pass-through) ──
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiCtrl,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    numberOfParticles: 35,
                    maxBlastForce: 22,
                    minBlastForce: 8,
                    emissionFrequency: 0.05,
                    gravity: 0.3,
                    colors: const [
                      Color(0xFFE53935), Color(0xFF1E88E5),
                      Color(0xFF43A047), Color(0xFFFFB300),
                      Color(0xFF8E24AA), Color(0xFF00ACC1),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Top bar (score + status + buttons) ─────────────────────────────────

  /// Một row duy nhất gọn gàng: [chip X] [status] [chip O] [↺] [⊗]
  Widget _buildTopBar(CaroController c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 6.h),
      child: Row(
        children: [
          _scoreChip('X', c.scoreX, AppColors.playerX,
              active: !c.gameOver && c.currentPlayer == 'X'),
          SizedBox(width: 6.w),
          _scoreChip('O', c.scoreO, AppColors.playerO,
              active: !c.gameOver && c.currentPlayer == 'O'),
          Spacer(),
          SizedBox(width: 8.w),
          _iconBtn(Icons.undo_rounded, c.undo, AppColors.buttonPrimary),
          SizedBox(width: 6.w),
          _iconBtn(Icons.refresh_rounded, c.resetGame, AppColors.buttonPrimary),
        ],
      ),
    );
  }

  Widget _scoreChip(String player, int score, Color color, {bool active = false}) {
    final borderColor = active
        ? AppColors.playerO
        : AppColors.playerO.withValues(alpha: 0.3);
    final bgColor = active ? color : AppColors.playerOLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor, width: active ? 2.5 : 1),
        boxShadow: active
            ? [BoxShadow(color: AppColors.playerO.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(player,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : color)),
        Text('$score',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : color)),
      ]),
    );
  }


  Widget _iconBtn(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: Colors.white, size: 18.r),
      ),
    );
  }

  // ─── Board ────────────────────────────────────────────────────────────────

  Widget _buildBoard(CaroController c) {
    return Padding(
      padding: EdgeInsets.symmetric( vertical: 0.h),
      child: LayoutBuilder(
        builder: (_, constraints) {
          const cols = 15;
          final cellSize = constraints.maxWidth / cols;
          final rows = (constraints.maxHeight / cellSize).floor().clamp(cols, 50);
          final boardH = cellSize * rows;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.applyBoardDimensions(cols, rows);
            // Mặc định zoom 2x, căn giữa board lần đầu
            if (!_zoomInitialized) {
              _zoomInitialized = true;
              const s = 1.3;
              final tx = -(constraints.maxWidth * (s - 1)) / 2;
              final ty = -(boardH * (s - 1)) / 2;
              _transformCtrl.value = Matrix4.identity()
                ..scaleByDouble(s, s, 1, 1)
                ..translateByDouble(tx / s, ty / s, 0, 1);
            }
          });

          return Container(
            width: constraints.maxWidth,
            height: boardH,
            decoration: BoxDecoration(
              color: AppColors.boardBackground,
              border: Border.all(color: AppColors.boardLine, width: 1),
            ),
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                minScale: 0.5,
                maxScale: 8.0,
                child: AnimatedBuilder(
                  animation: _lineProg,
                  builder: (context2, child2) => Stack(
                    children: [
                      // Grid
                      Column(
                        children: List.generate(
                          c.boardRows,
                          (row) => Expanded(
                            child: Row(
                              children: List.generate(
                                c.boardCols,
                                (col) => Expanded(child: _buildCell(c, row, col)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Win line overlay
                      if (c.gameOver && !c.isDraw && c.winningCells.isNotEmpty)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WinLinePainter(
                              winningCells: c.winningCells,
                              boardCols: c.boardCols,
                              boardRows: c.boardRows,
                              progress: _lineProg.value,
                              color: c.winnerName == 'X'
                                  ? AppColors.playerX
                                  : AppColors.playerO,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(CaroController c, int row, int col) {
    if (row >= c.board.length || col >= c.board[0].length) {
      return const SizedBox.shrink();
    }
    final piece     = c.board[row][col];
    final isWinning = c.isWinningCell(row, col);
    final isX       = piece == 'X';

    return GestureDetector(
      onTap: () => c.onCellTap(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: isWinning ? AppColors.winHighlightBg : Colors.transparent,
          border: Border.all(
            color: AppColors.boardLine.withValues(alpha: 0.45),
            width: 0.4,
          ),
        ),
        child: piece.isNotEmpty
            ? TweenAnimationBuilder<double>(
                key: ValueKey('$row-$col-$piece'),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Center(
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        piece,
                        style: TextStyle(
                          color: isWinning
                              ? AppColors.winHighlight
                              : (isX ? AppColors.playerX : AppColors.playerO),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // ─── Action buttons ───────────────────────────────────────────────────────

}

// ─── Win line painter ─────────────────────────────────────────────────────────

class _WinLinePainter extends CustomPainter {
  final List<List<int>> winningCells;
  final int boardCols;
  final int boardRows;
  final double progress;
  final Color color;

  const _WinLinePainter({
    required this.winningCells,
    required this.boardCols,
    required this.boardRows,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (winningCells.isEmpty || progress == 0) return;

    // Sắp xếp để lấy 2 đầu mút của chuỗi thắng
    final sorted = List<List<int>>.from(winningCells)
      ..sort((a, b) => a[0] != b[0] ? a[0].compareTo(b[0]) : a[1].compareTo(b[1])); // ignore: unnecessary_underscores

    final cellW = size.width  / boardCols;
    final cellH = size.height / boardRows;

    final start = Offset(
      (sorted.first[1] + 0.5) * cellW,
      (sorted.first[0] + 0.5) * cellH,
    );
    final end = Offset(
      (sorted.last[1] + 0.5) * cellW,
      (sorted.last[0] + 0.5) * cellH,
    );

    // Kéo dài thêm nửa ô mỗi đầu cho đẹp
    final delta = end - start;
    final length = delta.distance;
    if (length == 0) return;
    final unit = delta / length;
    final extStart = start - unit * (cellW * 0.5);
    final extEnd   = end   + unit * (cellW * 0.5);

    // Điểm đầu animate đến điểm cuối
    final animEnd = Offset.lerp(extStart, extEnd, progress)!;

    // Bóng mờ phía sau
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = cellW * 0.32
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(extStart, animEnd, shadowPaint);

    // Đường chính
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.82)
      ..strokeWidth = cellW * 0.22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(extStart, animEnd, linePaint);

    // Highlight trắng mỏng ở giữa (hiệu ứng bóng sáng)
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = cellW * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(extStart, animEnd, glowPaint);
  }

  @override
  bool shouldRepaint(_WinLinePainter old) =>
      old.progress != progress || old.winningCells.length != winningCells.length;
}
