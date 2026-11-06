import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Six visibly distinct boxes driven by a single native text input.
///
/// A single controller allows normal numeric typing, backspace, iOS SMS
/// autofill and pasting a full code without fragile per-box focus handlers.
/// The active visual position advances or retreats with the text length.
class AppOtpInput extends StatelessWidget {
  const AppOtpInput({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  static const int length = 6;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The 42px edge inset includes the existing 20px screen padding.
        // This leaves an additional 22px inset within the body.
        final available = math.max(0.0, constraints.maxWidth - 44);
        final width = math.min(48.0, available / length);
        final gap = available >= 48.0 * length
            ? (available - 48.0 * length) / (length - 1)
            : math.min(4.0, math.max(0.0, (available - width * length) / 5));
        // On compact devices use a minimum 4px gap and shrink the boxes.
        final compactWidth = available < 48.0 * length
            ? math.max(0.0, (available - 5 * 4.0) / length)
            : width;
        final boxWidth = available < 48.0 * length ? compactWidth : width;
        final boxGap = available < 48.0 * length ? 4.0 : gap;
        final rowWidth = boxWidth * length + boxGap * (length - 1);

        return Center(
          child: SizedBox(
            key: const Key('otp_row'),
            width: rowWidth,
            height: 48,
            child: Stack(
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final count = value.text.length;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(length, (index) {
                        final filled = index < count;
                        return Container(
                          key: Key('otp_box_$index'),
                          width: boxWidth,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.outlinedButtonBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.otpBorder,
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.otpShadow,
                                offset: Offset(0, 4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Text(
                            filled ? '*' : '•',
                            style: AppTypography.otpCharacter.copyWith(
                              color: filled
                                  ? AppColors.heading
                                  : AppColors.secondaryText,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    alwaysIncludeSemantics: true,
                    child: TextField(
                      key: const Key('otp_native_input'),
                      // A single native field supports paste and backspace.

                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      autocorrect: false,
                      enableSuggestions: false,
                      maxLength: length,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(length),
                      ],
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
