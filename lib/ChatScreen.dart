import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_ws/RecordsAndFetcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ChatMessage {
  final String userName;
  final String messageContent;
  final String messageType;
  final int id;

  const ChatMessage(
      {required this.userName,
      required this.messageContent,
      required this.messageType,
      required this.id});
}

typedef _Fn = void Function();

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({Key? key}) : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  FetchContent fc = FetchContent();
  
  List<ChatMessage> messages = [
    ChatMessage(
        messageContent: "Hello, Will",
        userName: "receiver",
        messageType: "text",
        id: 1),
    ChatMessage(
        messageContent: "How have you been?",
        userName: "receiver",
        messageType: "voice",
        id: 103),
    ChatMessage(
        messageContent: "Hey Kriss, I am doing fine dude. wbu?",
        userName: "sender",
        messageType: "text",
        id: 3),
    ChatMessage(
        messageContent: "ehhhh, doing OK.",
        userName: "receiver",
        messageType: "text",
        id: 4),
    ChatMessage(
        messageContent: "Is there any thing wrong?",
        userName: "sender",
        messageType: "text",
        id: 5),
    ChatMessage(
        messageContent: "Is there any thing wrong?",
        userName: "sender",
        messageType: "text",
        id: 6),
    ChatMessage(
        messageContent: "Is there any thing wrong?",
        userName: "sender",
        messageType: "text",
        id: 7),
  ];

  FlutterSoundPlayer? _dPlayer = FlutterSoundPlayer();
  bool _dPlayerIsInited = false;
  var path = '';

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  var url;
  var fromURI = 'app' + '.aac';
  final String user = 'app';
  final myController = TextEditingController();
  final String myURL = '10.0.2.2:5000';
  int currentId = 0;

  @override
  void initState() {
    _dPlayer!.openAudioSession().then((value) {
      setState(() {
        _dPlayerIsInited = true;
      });
    });

    _mPlayer!.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    //download all relevant voices
    getTemporaryDirectory().then((value) {
      setState(() {
        path = '${value.path}';
      });
    });
    for (ChatMessage chatmessage in messages) {
      if (chatmessage.messageType == "voice") {
        download(chatmessage.id);
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closeAudioSession();
    _mPlayer = null;
    _dPlayer!.closeAudioSession();
    _dPlayer = null;

    _mRecorder!.closeAudioSession();
    _mRecorder = null;
    myController.dispose();
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openAudioSession();
    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {
    _mRecorder!
        .startRecorder(
      toFile: fromURI,
      codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        url = value;
        _mplaybackReady = true;
      });
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    print(DateTime.now().millisecondsSinceEpoch.toString());
    _mPlayer!
        .startPlayer(
            fromURI: fromURI,
            codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  void dplay() {
    assert(_dPlayerIsInited);
    _dPlayer!
        .startPlayer(
            fromURI: path + "/" + currentId.toString() + ".aac",
            codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void dstopPlayer() {
    _dPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  void upload() async {
    final queryParameters = {
      'x': '1',
      'y': '1',
      'typ': 'comment',
      'username': 'app',
    };
    final response =
        await http.post(Uri.parse('http://' + myURL + '/api/elements/insert/'),
            headers: <String, String>{
              'Content-type': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'x': '1',
              'y': '1',
              'typ': '\"comment\"',
              'username': '\"app\"',
            }));

    final content = jsonDecode(response.body);

    var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://' +
            myURL +
            '/api/elements/' +
            content["id"].toString() +
            '/upload_voice/'));
    var voice = await http.MultipartFile.fromPath("file", url);
    request.files.add(voice);
    var res = await request.send();
    setState(() {});
  }

  void download(int id) async {
    final uri = Uri.http(myURL, '/api/voices/' + id.toString() + '/');
    final response = await http.get(uri);
    print(response.body);
    var tempDir = await getTemporaryDirectory();
    var path = '${tempDir.path}';
    var file = new File(path + "/" + id.toString() + ".aac");
    file.writeAsBytes(response.bodyBytes);
    setState(() {});
  }

  void deletePlayback(){
    _mplaybackReady = false;
    setState(() {});
  }

// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  _Fn? getUploadFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? upload : stopPlayer;
  }

  _Fn? getDownloadAndPlaybackFn(int id) {
    if (!_dPlayerIsInited) {
      return null;
    }
    currentId = id;
    return _dPlayer!.isStopped ? dplay : dstopPlayer;
  }

  _Fn? deletePlaybackFn() {
    if (!_mplaybackReady) {
      return null;
    }
    return deletePlayback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Kriss Benwat",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: <Widget>[
                ListView.builder(
                  itemCount: messages.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10, bottom: 60),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Align(
                        alignment: (messages[index].userName == "receiver"
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (messages[index].userName == "receiver"
                                ? Colors.grey.shade200
                                : Colors.blue[200]),
                          ),
                          padding: EdgeInsets.all(16),
                          child: (messages[index].messageType == "text"
                              ? Text(messages[index].messageContent,
                                  style: TextStyle(fontSize: 15))
                              : ElevatedButton(
                                  onPressed: getDownloadAndPlaybackFn(
                                      messages[index].id),
                                  //color: Colors.white,
                                  //disabledColor: Colors.grey,
                                  child: Text('Play'),
                                )),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: getRecorderFn(),
                    //color: Colors.white,
                    //disabledColor: Colors.grey,
                    child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: getPlaybackFn(),
                    //color: Colors.white,
                    //disabledColor: Colors.grey,
                    child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: deletePlaybackFn(),
                    //color: Colors.white,
                    //disabledColor: Colors.grey,
                    child: Text(_mplaybackReady ? 'Delete' : 'Empty'),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: myController,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      setState(
                        () {
                          if (_mplaybackReady) {
                            messages.add(ChatMessage(
                                messageContent: "",
                                userName: "sender",
                                messageType: "voice",
                                id: 8));
                          } else {
                            messages.add(ChatMessage(
                                messageContent: myController.text,
                                userName: "sender",
                                messageType: "text",
                                id: 8));
                            myController.text = "";
                          }
                        },
                      );
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
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
