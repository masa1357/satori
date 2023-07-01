import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:logger/logger.dart';
import 'dart:async';

void main() {
  runApp(Recorder());
}

// var logger = Logger(
//   printer: PrettyPrinter(
//     errorMethodCount: 2, // number of method calls to be displayed
//     colors: true, // Colorful log messages
//     printEmojis: true, // Print an emoji for each log message
//   ),
// );

class Recorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Record',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Record'),
        ),
        body: Center(
          child: WindowBody(),
        ),
      ),
    );
  }
}

class WindowBody extends StatefulWidget {
  @override
  _WindowBodyState createState() => _WindowBodyState();
}

class _WindowBodyState extends State<WindowBody> {
  bool _status = false;
  bool _flag = false;
  final record = Record();
  String? pathToWrite;
  final logger = Logger();

  void _startRecording() async {
    // 録音を開始する
    logger.i("Start recording $_flag");
    await record.hasPermission();
    final directory = await getApplicationDocumentsDirectory();
    pathToWrite = directory.path + '/kari.wav';
    await record.start(
      path: pathToWrite,
      //encoder: AudioEncoder.pcm16bit,
      bitRate: 128000,
      samplingRate: 11025,
    );
  }

  void _stopRecording() async {
    // 録音を停止する
    logger.w("Stop recording");
    await record.stop();
    // var logger = Logger();
    // logger.i("Logger is working!");
    // FFmpegKitConfig.selectDocumentForWrite('$pathToWrite/kari.wav', 'audio/*')
    //     .then((uri) {
    //   FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) {
    //     // FFmpegKit.executeAsync(
    //     //     "-i '$pathToWrite/kari.m4a' -c:a pcm_s16le ${safUrl}");
    //     FFmpegKit.executeAsync(
    //             "-i '$pathToWrite/kari.m4a' -c:a pcm_s16le ${safUrl}")
    //         .then((session) async {
    //       final returnCode = await session.getReturnCode();
    //       if (ReturnCode.isSuccess(returnCode)) {
    //         logger.i("Conversion completed successfully.");
    //       } else if (ReturnCode.isCancel(returnCode)) {
    //         logger.e("Conversion cancelled by user.");
    //       } else {
    //         logger.e("Conversion failed with return code: $returnCode");
    //       }
    //     });
    //   });
    // });
  }

  void _startPlaying() async {
    // 再生する
    final logger = Logger();
    AudioPlayer audioPlayer = AudioPlayer();
    final directory = await getApplicationDocumentsDirectory();
    String pathToWrite = directory.path + '/kari.wav';
    logger.i('Start Play!!');
    await audioPlayer.play(DeviceFileSource(pathToWrite));
    logger.i('Finish Play!!');
  }

  void _recordSwitch() {
    setState(() {
      _status = !_status;
      if (_status) {
        _startRecording();
      } else {
        _stopRecording();
        //_startPlaying();
      }
    });
  }

  Timer? _timer;
  void _startTimer() async {
    final logger = Logger();
    _flag = !_flag;
    if (_flag) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _recordSwitch();
      });
    } else {
      logger.w("Canceled Timer!! $_flag");
      _stopTimer();
      _stopRecording();
    }
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: <Widget>[
            Text((_flag ? "録音中..." : "録音ボタンを押してね！"),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: "RondeB",
                )),
            TextButton(
                onPressed: _startTimer,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  backgroundColor: Colors.tealAccent,
                  shadowColor: Colors.teal,
                  elevation: 5,
                ),
                child: Text((_flag ? "停止" : "開始"),
                    style: const TextStyle(
                        color: Color.fromARGB(255, 187, 52, 52),
                        fontSize: 40.0)))
          ],
        ));
  }
}
