import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final videoURL = 'https://www.youtube.com/watch?v=ir46Iv4q7Mg';
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    final videoID = YoutubePlayer.convertUrlToId(videoURL);
    _controller = YoutubePlayerController(
      initialVideoId: videoID!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text(
          'FAQs',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
              ),
            ],
          );
        },
      ),
      // body: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Flexible(
      //       child: YoutubePlayer(
      //         controller: _controller,
      //         showVideoProgressIndicator: true,
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}