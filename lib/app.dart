import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme.dart';

class BodyAtlasApp extends StatelessWidget {
  const BodyAtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
