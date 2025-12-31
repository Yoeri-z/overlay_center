import 'package:flutter/material.dart';

extension ScaffoldMessengerExtension on BuildContext {
  /// Shows a snackbar in the current scaffold messenger.
  void showSnackBar(
    SnackBar snackBar, {
    Duration? duration,
    AnimationStyle? snackBarAnimationStyle,
  }) async {
    final control = ScaffoldMessenger.of(
      this,
    ).showSnackBar(snackBar, snackBarAnimationStyle: snackBarAnimationStyle);

    if (duration != null) {
      await Future.delayed(duration);

      control.close();
    }
  }

  /// Shows a bottom sheet in the current scaffold.
  /// if [duration] is provided bottom sheet closes automatically after the given duration.
  void showBottomSheet(Widget sheet, {Duration? duration}) async {
    final control = Scaffold.of(this).showBottomSheet((context) => sheet);

    if (duration != null) {
      await Future.delayed(duration);
      control.close();
    }
  }

  /// Shows a material banner in the current scaffold.
  /// if [duration] is provided bottom sheet closes automatically after the given duration.
  void showMaterialBanner(MaterialBanner banner, {Duration? duration}) async {
    final control = ScaffoldMessenger.of(this).showMaterialBanner(banner);

    if (duration != null) {
      await Future.delayed(duration);

      control.close();
    }
  }
}
