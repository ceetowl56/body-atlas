import 'package:flutter/material.dart';

import '../ads/ad_service.dart';
import '../ads/banner_ad_widget.dart';
import 'learn_screen.dart';
import 'progress_screen.dart';
import 'quiz_screen.dart';

/// Main screen with bottom navigation: Learn, Quiz, Progress.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    LearnScreen(),
    QuizScreen(),
    ProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Ask for ad consent (if required) and start ads after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Learn',
              ),
              NavigationDestination(
                icon: Icon(Icons.quiz_outlined),
                selectedIcon: Icon(Icons.quiz),
                label: 'Quiz',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: 'Progress',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
