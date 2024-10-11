import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class FullScreenVideoPlayer extends StatefulWidget {
   VideoPlayerController controller;
  final List<FileSystemEntity> videoFiles;
  final int initialIndex;

   FullScreenVideoPlayer({
    Key? key,
    required this.controller,
    required this.videoFiles,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late int _currentIndex;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.controller.addListener(() {
      setState(() {}); // Update the screen when the video state changes
    });
    widget.controller.play(); // Automatically play the video when screen opens
  }

  void _playNextVideo() {
    if (_currentIndex < widget.videoFiles.length - 1) {
      _currentIndex++;
      _loadVideo(_currentIndex);
    }
  }

  void _loadVideo(int index) {
    widget.controller.pause();
    widget.controller.seekTo(Duration.zero);
    widget.controller.removeListener(() {});
    widget.controller = VideoPlayerController.file(File(widget.videoFiles[index].path))
      ..initialize().then((_) {
        setState(() {
          widget.controller.play();
        });
      });
  }

  @override
  void dispose() {
    widget.controller.dispose(); // Dispose the controller when screen is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: widget.controller.value.isInitialized
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: widget.controller.value.aspectRatio,
                    child: VideoPlayer(widget.controller),
                  ),
                  if (!_isLocked)
                    _ControlsOverlay(
                      controller: widget.controller,
                      onNext: _playNextVideo,
                      onLock: () {
                        setState(() {
                          _isLocked = !_isLocked;
                        });
                      },
                      isLocked: _isLocked,
                    ),
                  VideoProgressIndicator(widget.controller, allowScrubbing: true),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onNext;
  final VoidCallback onLock;
  final bool isLocked;

  const _ControlsOverlay({
    Key? key,
    required this.controller,
    required this.onNext,
    required this.onLock,
    required this.isLocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_next, size: 30.0, color: Colors.white),
                onPressed: onNext,
              ),
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 50.0,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.value.isPlaying ? controller.pause() : controller.play();
                },
              ),
              IconButton(
                icon: Icon(
                  isLocked ? Icons.lock_open : Icons.lock,
                  size: 30.0,
                  color: Colors.white,
                ),
                onPressed: onLock,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
