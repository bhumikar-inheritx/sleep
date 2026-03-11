import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A transparent app bar specifically styled for the sleep app's dark theme.
class SleepAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool transparent;

  const SleepAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.transparent = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      leading: leading,
      actions: actions,
      backgroundColor: transparent ? Colors.transparent : null,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
