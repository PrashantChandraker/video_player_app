import 'package:flutter/material.dart';

import 'package:video_player_app/home_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoListScreen(),
    );
  }
}

