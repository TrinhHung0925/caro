import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../resource/app_colors.dart';
import '../../service/audio_service.dart';
import 'home_controller.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key}) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final controller = Get.find<HomeController>();
  final audio = Get.find<AudioService>();
  late AnimationController _titleAnim;
  late Animation<double> _titleScale;

  @override
  void initState() {
    super.initState();
    _titleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _titleScale = CurvedAnimation(parent: _titleAnim, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _titleAnim.dispose();
    Get.delete<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B5E), Color(0xFF1A237E), Color(0xFF283593)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 48.h),
                _buildTitle(),
                SizedBox(height: 40.h),
                _buildSettingsCard(),
                const Spacer(),
                _buildPlayButton(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ScaleTransition(
      scale: _titleScale,
      child: Column(
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '⊞',
                style: TextStyle(fontSize: 44.sp, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'CARO',
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          Text(
            'GOMOKU GAME',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          _buildMusicToggle(),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 28.h),
          _buildWinModeSelector(),
        ],
      ),
    );
  }

  Widget _buildMusicToggle() {
    return Obx(() {
      final enabled = audio.isMusicEnabled.value;
      return Row(
        children: [
          Icon(
            enabled ? Icons.music_note : Icons.music_off,
            color: Colors.white,
            size: 22.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Nhạc nền',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: controller.toggleMusic,
            activeThumbColor: const Color(0xFF69F0AE),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      );
    });
  }

  Widget _buildWinModeSelector() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_outlined,
                  color: Colors.white, size: 22.r),
              SizedBox(width: 12.w),
              Text(
                'Điều kiện thắng',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [3, 4, 5].map((mode) {
              final selected = controller.winMode.value == mode;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: GestureDetector(
                    onTap: () => controller.setWinMode(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$mode',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                          Text(
                            'quân',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.startGame,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 28.r),
            SizedBox(width: 8.w),
            Text(
              'BẮT ĐẦU CHƠI',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
