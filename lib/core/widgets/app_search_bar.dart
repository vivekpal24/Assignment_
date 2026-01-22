
import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

/// A custom search bar widget with clear functionality.
///
/// Displays a text field with a search icon and an optional clear button
/// that appears when text is entered.
class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = AppStrings.searchHint,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late bool _showClear;

  @override
  void initState() {
    super.initState();
    _showClear = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_listener);
  }

  void _listener() {
    final shouldShow = widget.controller.text.isNotEmpty;
    if (_showClear != shouldShow) {
      setState(() => _showClear = shouldShow);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _showClear
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: widget.onClear,
              )
            : null,
      ),
      onChanged: widget.onChanged,
    );
  }
}
