import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:video_player_app/video_player_sreen.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<FileSystemEntity> _files = [];
  VideoPlayerController? _controller;
  // late PermissionStatus permissionStatus;
  @override
  void initState() {
    super.initState();
     _checkPermissions();
    // if(permissionStatus.isDenied){
    //     _checkPermissions();
    // }
  
  }

  // Future<void> _checkPermissions() async {
  //   print("t2");
  //   var status = await Permission.storage.status;
  //   print("t1");
  //   print("permission status ==> $status");

  //   //permission denied
  //   if (status.isDenied) {
  //     final permissionStatus = await Permission.manageExternalStorage.request();
  //     if (permissionStatus.isGranted) {
  //       print("Permission granted");
  //       _getFiles();
  //     } else {
  //       print("Permission not granted");
  //       _showPermissionDialog();
  //     }
  //   } else if (status.isRestricted) {
  //     print("The device Permission is restricted");
  //   } else if (status.isGranted) {
  //     print("Permission already granted");
  //     _getFiles();
  //   }
  // }

  Future<void> _checkPermissions() async {
    final permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
      // Here just ask for the permission for the first time
      print("1");
      await Permission.manageExternalStorage.request();

      // I noticed that sometimes popup won't show after user press deny
      // so I do the check once again but now go straight to appSettings
      // if (permissionStatus.isDenied) {
      //   print("3");
      //   await openAppSettings();
      //   print("4");
      // }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Here open app settings for user to manually enable permission in case
      // where permission was permanently denied
      print("5");
      await openAppSettings();
      print("6");
    } else {
      // Do stuff that require permission here
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text("Please grant storage permission to access videos"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkPermissions();
              print("a1");
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _getFiles() async {
    Directory? directory;
    String customPath = '/storage/emulated/0/Download';
    print("s1");
    if (Platform.isAndroid) {
      print("s2");
      directory = Directory(customPath);
      print("s3");
    } else {
      print("s4");
      directory = await getApplicationDocumentsDirectory();
      print("s4");
    }

    if (directory.existsSync()) {
      print("directory 1 ==> ${directory.path}");
      List<FileSystemEntity> files = directory
          .listSync()
          .where((entity) => entity.path.endsWith('.mp4'))
          .toList();
      print("List of videos ${files}");
      setState(() {
        _files = files;
      });
    } else {
      print("Failed to get directory");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video List'),
      ),
      body: _files.isEmpty
          ? const Center(child: Text('No videos found'))
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              itemCount: _files.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _playVideo(_files[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Card(
                      elevation: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.video_library,
                            size: 50,
                          ),
                          const SizedBox(width: 20),
                          Text(_files[index].path.split('/').last),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _playVideo(FileSystemEntity file) {
    if (_controller != null) {
      _controller!.dispose();
    }
    int initialIndex = _files.indexOf(file);
    setState(
      () {
        _controller = VideoPlayerController.file(File(file.path))
          ..initialize().then(
            (_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenVideoPlayer(
                    controller: _controller!,
                    videoFiles: _files,
                    initialIndex: initialIndex,
                  ),
                ),
              );
            },
          );
      },
    );
  }
}
