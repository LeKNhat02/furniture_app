import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final List<PopupMenuEntry>? menuItems;
  final Widget? leading;
  final bool showSearch;
  final Function(String)? onSearch;
  final Color backgroundColor;
  final Color? textColor;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onMenuPressed,
    this.menuItems,
    this.leading,
    this.showSearch = false,
    this.onSearch,
    this.backgroundColor = const Color(0xFF1976D2),
    this.textColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: leading ?? (onMenuPressed != null
          ? IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
      )
          : null),
      actions: [
        if (showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: SizedBox(
                width: 150,
                height: 40,
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        if (menuItems != null && menuItems!.isNotEmpty)
          PopupMenuButton(
            itemBuilder: (context) => menuItems!,
            icon: const Icon(Icons.more_vert),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Custom app bar with back button
class CustomAppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final List<PopupMenuEntry>? menuItems;
  final Color backgroundColor;
  final Color? textColor;
  final double elevation;

  const CustomAppBarWithBack({
    Key? key,
    required this.title,
    required this.onBackPressed,
    this.menuItems,
    this.backgroundColor = const Color(0xFF1976D2),
    this.textColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      actions: [
        if (menuItems != null && menuItems!.isNotEmpty)
          PopupMenuButton(
            itemBuilder: (context) => menuItems!,
            icon: const Icon(Icons.more_vert),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}