import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../common/common.dart';
import 'custom_loader.dart';

class CustomSliderButton extends StatefulWidget {
  final String buttonName;
  final double? height;
  final double? width;
  final Color? buttonColor;
  final Color? textColor;
  final double? textSize;
  final Future<bool?> Function() onSlideSuccess;
  final bool? isLoader;
  final Widget? sliderIcon;

  const CustomSliderButton({
    super.key,
    required this.buttonName,
    this.height,
    this.width,
    this.buttonColor,
    this.textColor,
    this.textSize,
    required this.onSlideSuccess,
    this.isLoader = false,
    this.sliderIcon,
  });

  @override
  State<CustomSliderButton> createState() => _CustomSliderButtonState();
}

class _CustomSliderButtonState extends State<CustomSliderButton>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> sliderPosition = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isSliding = ValueNotifier<bool>(false);

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonHeight = widget.height ?? size.width * 0.13;
    final buttonWidth = widget.width ?? size.width * 0.75;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        sliderPosition.value = (details.localPosition.dx)
            .clamp(0.0, buttonWidth - (buttonHeight / 2));
      },
      onHorizontalDragEnd: (details) async {
        if (sliderPosition.value >= buttonWidth - (buttonHeight / 2) - 10) {
          HapticFeedback.vibrate();
          isSliding.value = true;
          final success = await widget.onSlideSuccess();
          if (success == true) {
            sliderPosition.value = 0.0;
          }
          isSliding.value = false;
        } else {
          sliderPosition.value = 0.0;
        }
      },
      child: SizedBox(
        height: buttonHeight,
        width: buttonWidth,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                      stops: const [0.5, 0.5, 1.5],
                      begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
                      end: Alignment(1.0 + _shimmerController.value * 2, 0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      color:
                          widget.buttonColor ?? Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
            Center(
              child: ValueListenableBuilder<bool>(
                valueListenable: isSliding,
                builder: (context, sliding, child) {
                  return Shimmer.fromColors(
                    baseColor:
                        widget.textColor?.withOpacity(0.6) ?? AppColors.white,
                    highlightColor:
                        widget.textColor ?? AppColors.grey.withOpacity(0.6),
                    child: Text(
                      sliding ? '' : widget.buttonName,
                      style: AppTextStyle.boldStyle().copyWith(
                        color: widget.textColor ?? AppColors.white,
                        fontSize: widget.textSize ?? 18,
                      ),
                    ),
                  );
                },
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: sliderPosition,
              builder: (context, value, child) {
                return Positioned(
                  left: (value <= buttonWidth - buttonHeight)
                      ? value
                      : buttonWidth - buttonHeight,
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        height: buttonHeight,
                        width: buttonHeight, // Square sliding button
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white),
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.grey.withOpacity(0.5),
                              AppColors.grey,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0.0, 1.0],
                            transform: GradientRotation(
                                _shimmerController.value *
                                    6.283), // Shimmer rotation
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isSliding,
                          builder: (context, sliding, child) {
                            return sliding
                                ? Center(
                                    child: SizedBox(
                                      height: size.width * 0.05,
                                      width: size.width * 0.05,
                                      child: const Loader(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      child: widget.sliderIcon ??
                                          Shimmer.fromColors(
                                            baseColor: AppColors.primary
                                                .withOpacity(0.6),
                                            highlightColor: AppColors.primary,
                                            child: Icon(
                                              Icons
                                                  .keyboard_double_arrow_right_rounded,
                                              color: AppColors.white,
                                              size: size.width * 0.07,
                                            ),
                                          ),
                                    ),
                                  );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
