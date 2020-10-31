import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:watson_assistant_v2/watson_assistant_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AssistantPage extends StatefulWidget {
  @override
  _AssistantPageState createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  String Itext='';

  final FlutterTts flutterTts = FlutterTts();

  Future speak(String text) async{
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1);
    await flutterTts.setSpeechRate(0.75);
    await flutterTts.speak(text);
  }

  WatsonAssistantV2Credential credential = WatsonAssistantV2Credential(
    version: '2019-02-28',
    username: 'apikey',
    apikey: 'BoAhawDWYJXFkK8oEcxaPjTGU-UpVO_tHB2IXzJiqC6_',
    assistantID: 'c651ffe6-41ca-49d4-bf95-fd78da397be7',
    url: 'https://api.kr-seo.assistant.watson.cloud.ibm.com/instances/249a6829-1928-46a0-813e-a31e0aef9f74/v2',
  );

  WatsonAssistantApiV2 watsonAssistant;
  WatsonAssistantResponse watsonAssistantResponse;
  WatsonAssistantContext watsonAssistantContext =
  WatsonAssistantContext(context: {});

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    watsonAssistant =
        WatsonAssistantApiV2(watsonAssistantCredential: credential);
    speak('Hello, How Can I Help You');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(top: 160),
        child: Column(
          children: [
            AvatarGlow(
              animate: _isListening,
              glowColor: Colors.yellow,
              endRadius: 75.0,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              child: IconButton(
                color: Colors.black,
                onPressed: () {
                  _listen();
                  setState(() {
                    Itext='';
                    _text='';
                  });
                },
                iconSize: 96,
                icon: GradientIcon(
                  FlutterIcons.mic_fea,
                  96.0,
                  LinearGradient(
                    colors: <Color>[
                      Colors.red,
                      Colors.yellow,
                      Colors.blue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Text(
              'Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage('images/Assistant Background.jpg'),
              fit: BoxFit.cover,
            )
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.75),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        reverse: true,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(35.0, 200.0, 35.0, 50.0),
                          child: Text(
                            _text,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        reverse: true,
                        child: Itext!=''? Container(
                          padding: const EdgeInsets.only(left: 35.0,right: 35.0),
                          child: Text(
                            Itext,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ): Text(''),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() async {
            _text = val.recognizedWords;
            if(_text=='Mute') {
              await flutterTts.stop();
              _isListening=false;
              _speech.stop();
            }
            else{
              watsonAssistantResponse = await watsonAssistant.sendMessage(
                  _text, watsonAssistantContext);
              Itext = watsonAssistantResponse.resultText;
              await flutterTts.setLanguage("en-IN");
              await flutterTts.setPitch(1);
              await flutterTts.setSpeechRate(0.75);
              await flutterTts.speak(Itext);
              watsonAssistantContext = watsonAssistantResponse.context;
              setState(() {
                _isListening=false;
              });
            }
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}

class GradientIcon extends StatelessWidget {
  GradientIcon(
      this.icon,
      this.size,
      this.gradient,
      );

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: GlowIcon(
          icon,
          size: size-4,
          color: Colors.white,
          glowColor: Colors.white,
          blurRadius: 15,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, size, size);
        return gradient.createShader(rect);
      },
    );
  }
}
