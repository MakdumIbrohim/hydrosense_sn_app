import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_top_bar.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Alignment _alignment = Alignment.bottomCenter;
  bool _showDragHint = false;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _checkHintStatus();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkHintStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hide = prefs.getBool('hide_drag_hint') ?? false;
    if (!hide) {
      if (mounted) {
        setState(() => _showDragHint = true);
        // Hilang otomatis dalam 5 detik
        _hintTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) setState(() => _showDragHint = false);
        });
      }
    }
  }

  Future<void> _dismissHint() async {
    _hintTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hide_drag_hint', true);
    if (mounted) setState(() => _showDragHint = false);
  }

  void _onPanEnd(DragEndDetails details, Size size) {
    final Offset velocity = details.velocity.pixelsPerSecond;
    
    // Periksa apakah tarikan cukup kuat (fling)
    if (velocity.distance > 300) {
      if (velocity.dx.abs() > velocity.dy.abs()) {
        _alignment = velocity.dx > 0 ? Alignment.centerRight : Alignment.centerLeft;
      } else {
        _alignment = velocity.dy > 0 ? Alignment.bottomCenter : Alignment.topCenter;
      }
      setState(() {});
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    // Kosongkan agar panel tidak langsung kabur dari jari saat disentuh.
    // Perpindahan hanya dipicu saat jari dilepas (onPanEnd) dengan sedikit lemparan (swipe).
  }

  Widget _buildDragHintBubble() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                const Text('Tips Fitur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Panel navigasi ini bisa diseret & dilempar (swipe) ke tepi layar lho!', 
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _dismissHint,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'JANGAN TAMPILKAN LAGI', 
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final axis = (_alignment == Alignment.centerLeft || _alignment == Alignment.centerRight) 
        ? Axis.vertical 
        : Axis.horizontal;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Konten Utama (Dibatasi 450px di tengah layar)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: widget.navigationShell,
            ),
          ),
          // Bar Navigasi (Bebas bergerak ke ujung layar laptop/HP)
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: _alignment,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onPanUpdate: (details) => _onPanUpdate(details, size),
                    onPanEnd: (details) => _onPanEnd(details, size),
                    child: CustomTopBar(
                      axis: axis,
                      selectedIndex: widget.navigationShell.currentIndex,
                      onItemTapped: (index) {
                        widget.navigationShell.goBranch(
                          index,
                          initialLocation: index == widget.navigationShell.currentIndex,
                        );
                      },
                    ),
                  ),
                  if (_showDragHint)
                    Positioned(
                      top: (_alignment == Alignment.topCenter) ? null : -100,
                      bottom: (_alignment == Alignment.topCenter) ? -100 : null,
                      left: (_alignment == Alignment.centerRight) ? -240 : 20,
                      child: _buildDragHintBubble(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
