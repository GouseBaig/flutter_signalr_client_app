import 'package:flutter/material.dart';
import 'package:flutter_signalr_client_app/core/base/widget/animations.dart';
import 'package:flutter_signalr_client_app/core/config/size_config.dart';
import 'package:flutter_signalr_client_app/core/theme/app_colors.dart';

showDownTimeDialog({
  required Widget content,
  String? title,
  required BuildContext context,
  bool? showCloseButton = false,
  bool? barrierDismissible = true,
  Color titleColor = AppColors.primaryColor,
}) async {
  return showGeneralDialog(
    context: context,
    barrierLabel: '',
    barrierDismissible: barrierDismissible ?? true,
    barrierColor: AppColors.purpleColor.withOpacity(0.6),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return Animations.grow(animation, secondaryAnimation, child);
    },
    pageBuilder: (animation, secondaryAnimation, child) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: SizeConfig.screenWidth * 0.85, // ✅ Actual width here
              minWidth: 200,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.whiteColor,
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SuisseIntl',
                            ),
                          ),
                        ),
                        if (showCloseButton ?? false)
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close),
                            splashRadius: 20,
                          )
                      ],
                    ),
                  const SizedBox(height: 20),
                  content,
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
