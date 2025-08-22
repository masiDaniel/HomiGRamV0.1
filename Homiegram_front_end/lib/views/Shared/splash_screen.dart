import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool isImageSplash =
      false; // Flag to determine if we're using an image splash
  bool navigationTriggered = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();

    // Decide whether to use an image or a video
    isImageSplash = true;

    if (!isImageSplash) {
      // Initialize the video controller
      _videoController = VideoPlayerController.asset(
          'assets/videos/splash_video.mp4')
        ..initialize().then((_) {
          setState(() {}); // Refresh the widget once the video is initialized
          _videoController?.play();
          _videoController?.setLooping(false);

          // Schedule navigation to the next screen when the video ends
          _videoController!.addListener(() {
            if (_videoController!.value.position >=
                    _videoController!.value.duration &&
                !navigationTriggered) {
              _navigateToNextScreen();
            }
          });
        }).catchError((error) {
          debugPrint('Video initialization failed: $error');
          _navigateToNextScreen(); // Fallback to navigation if video fails
        });
    } else {
      // Navigate after a delay if using an image
      Timer(const Duration(seconds: 4), () {
        _navigateToNextScreen();
      });
    }
  }

  void _navigateToNextScreen() {
    if (mounted && !navigationTriggered) {
      navigationTriggered = true; // Ensure navigation happens only once
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: isImageSplash
              ? Image.asset(
                  'assets/images/splash.jpeg', // Replace with your image path
                  fit: BoxFit.scaleDown,
                )
              : _videoController != null &&
                      _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.green, // Custom color
                          strokeWidth: 6.0, // Thicker stroke
                        ),
                        SizedBox(height: 10),
                        Text("Loading, please wait...",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    )), // Show a loader until the video is ready
        ),
      ),
    );
  }
}
