import 'package:flutter/material.dart';

extension ScaffoldMessengerExtension on BuildContext {
  /// Shows a snackbar in the current scaffold messenger.
  void showSnackBar(
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(snackBar, snackBarAnimationStyle: snackBarAnimationStyle);
  }

  /// Shows a bottom sheet in the current scaffold.
  /// if [duration] is provided bottom sheet closes automatically after the given duration.
  void showBottomSheet(Widget sheet, {Duration? duration}) {
    final control = Scaffold.of(this).showBottomSheet((context) => sheet);

    if (duration != null) {
      Future.delayed(duration, () => control.close());
    }
  }

  /// Shows a material banner in the current scaffold.
  /// if [duration] is provided bottom sheet closes automatically after the given duration.
  void showMaterialBanner(MaterialBanner banner, {Duration? duration}) {
    final control = ScaffoldMessenger.of(this).showMaterialBanner(banner);

    if (duration != null) {
      Future.delayed(duration, () => control.close());
    }
  }
}
