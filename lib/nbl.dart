import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

class nearby_Hospitals extends StatefulWidget {
  @override
  _nearbyHospitalsState createState() => _nearbyHospitalsState();
}

class _nearbyHospitalsState extends State<nearby_Hospitals> {

  List<String> hospital_name = [];
  List<String> hospital_address = [];
  List<String> hospital_phone_no = [];

  @override
  void initState() {
    // TODO: implement initState
    _getCurrentLocation();
    languageTranslator(word);
    super.initState();
  }

  String word = 'List Of Nearby Hospitals';

  void languageTranslator(String text) async {
    IamOptions options = await IamOptions(iamApiKey: "zPd4_juFPVV42husl_hmBH_oHgw90ktzPFVpkX-TdMfA", url: "https://api.kr-seo.language-translator.watson.cloud.ibm.com/instances/1d7be1f0-3162-4a87-a954-7e7e6e154ff3").build();
    LanguageTranslator service = new LanguageTranslator(iamOptions: options);
    TranslationResult translationResult = await service.translate(text, Language.ENGLISH, Language.HINDI);
    word=translationResult.toString();
  }

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;

  Future<Position> _getCurrentLocation() async{
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}-${place.administrativeArea}".toLowerCase().replaceAll(" ", "-");
        getdata(_currentAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  getdata(String add) async{
    String url = 'https://www.medicineindia.org/hospitals-in-city/'+add;
    var response = await http.get(url);
    dom.Document document = parser.parse(response.body);
    final mainclass = document.getElementsByClassName('table-responsive')[0].getElementsByTagName('tr');
    for(int i=0;i<mainclass.length;i++){
      try{
        String l=mainclass[i].getElementsByTagName('span')[0].innerHtml.toString();
        String td=mainclass[i].getElementsByTagName('td')[0].innerHtml.toString();
        var url1 = 'https://'+td.substring(46+l.length,td.length-l.length-35);
        var detail_response = await http.get(url1);
        dom.Document detail = parser.parse(detail_response.body);
        final subclass = detail.getElementById('main').getElementsByTagName('dl')[0].getElementsByTagName('div')[0].getElementsByTagName('dd');
        setState(() {
          hospital_name.add(l.toString());
          hospital_address.add(subclass[0].innerHtml.toString());
          hospital_phone_no.add(subclass[5].innerHtml.toString());
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(15)
                    )
                ),
                backgroundColor: Color(0xff3AB83A),
                expandedHeight: MediaQuery.of(context).size.height/3,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('Nearby Hospitals',style: TextStyle(letterSpacing: 2)),
                  background: Container(
                    height: MediaQuery.of(context).size.height/3,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                          zoom: 16.0
                      ),
                      zoomGesturesEnabled: true,
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ListView.builder(
                              itemCount: hospital_name.length,
                              itemBuilder: (context, i){
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Card(
                                    elevation: 10.0,
                                    color: Colors.white,
                                    child: ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                            border : Border(
                                                right: BorderSide(width: 1, color: Color(0xff3AB83A))
                                            )
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Color(0xff3AB83A),
                                          child: Text(hospital_name[i].substring(0,1), style: TextStyle(color: Colors.white70)),
                                        ),
                                      ),
                                      title: Text(hospital_name[i], style: TextStyle(color: Color(0xff3AB83A))),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.only(top: 6, bottom: 6),
                                            child: Text('Address :   '+hospital_address[i]),
                                          ),
                                          Text('Contact :   '+hospital_phone_no[i]),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]
        ),
      ),
    );
  }
}