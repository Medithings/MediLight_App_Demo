import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:ble_uart/versions//patient_ver/between_screen.dart';
import 'package:ble_uart/utils/ble_info_provider.dart';
import 'package:ble_uart/utils/extra.dart';
import 'package:ble_uart/utils/parsing_ac_gy.dart';
import 'package:ble_uart/utils/parsing_measured.dart';
import 'package:ble_uart/widgets/graph_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../../utils/parsing_temperature.dart';
import '../../../utils/shared_prefs_utils.dart';
import '../../../utils/database.dart';

final pageBucket = PageStorageBucket();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // @override
  // bool get wantKeepAlive => true;

  // static const String rx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // write data to the rx characteristic to send it to the UART interface.
  // static const String tx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Enable notifications for the tx characteristic to receive data from the application.
  //
  // late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  // late StreamSubscription<List<int>> _lastValueSubscription;
  //
  // late BluetoothDevice device;
  // late BluetoothService service;
  // late List<BluetoothCharacteristic> characteristic;

  // BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  late Route route = MaterialPageRoute(builder: (context) => const BetweenScreen());

  bool _isConnected = true;
  // int? _rssi;

  // int idxTx = 1;
  // int idxRx = 0;

  List<String> msg = [];
  List<String> tjmsg = [];

  int patchState = 0;
  double battery = 0.0;

  String todayString = "";

  bool measuring = false;
  // bool didInitialSet = false;
  // bool areYouGoingToWrite = false;

  late int level;
  late int maxLevel;
  late int levelIdx;
  late double riveIdx;
  late StateMachineController _stmController;
  SMIInput<double>? _numberExampleInput;
  ValueNotifier<double> batteryValue = ValueNotifier(0);

  List<String> cmtTitle = ["\nFREE", "\nPREPARE", "\n!!WARNING!!"];
  List<Color> cmtColors = [Colors.green, Colors.orange, Colors.red];
  List<Color> cardColors = [const Color.fromRGBO(200,225,204, 1), const Color.fromRGBO(255,215,105, 1), const Color.fromRGBO(253,216,216,1)];
  List<Color> infoColors = [const Color.fromRGBO(143,182,171, 1), const Color.fromRGBO(231,159,49, 1), const Color.fromRGBO(238,114,114,1)];
  List<Color> batteryColors = [const Color.fromRGBO(200,225,204, 1), const Color.fromRGBO(255,215,105, 1), const Color.fromRGBO(253,216,216,1)];

  int dayPer = 0;

  List<String> measuredTime = [];
  DateTime current = DateTime.now();
  late Stream timer;

  final spu = SharedPrefsUtil();

  late bool didPassBetween;
  late double temperature;

  late String timeStampForDBETC;

  List<int> levelIndexForEx = [];
  int levelCurrentIndexForEx = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    if(kDebugMode){
      print("[HomeScreen] !!Init state start!!");
      print("[HomeScreen] patch state is $patchState");
    }

    todayString = DateFormat.yMMMd().format(DateTime.now());
    // didPassBetween = context.read<BLEInfoProvider>().didPassBetween;

    maxLevel = spu.maxLevel;
    dayPer = spu.per;

    didPassBetween = false;
    print("didPassBetween : $didPassBetween");

    // if(!didPassBetween){
    //   device = context.read<BLEInfoProvider>().device;
    //   service = context.read<BLEInfoProvider>().service;
    //   characteristic = service.characteristics;
    // }

    msg.clear();
    tjmsg.clear();
    measuredTime.clear();

    // didInitialSet = false;
    // areYouGoingToWrite = false;

    setState(() {
      level = 0;
      levelIdx = 0;
      batteryValue.value = 400;
      riveIdx = 0;
      temperature = 0;

      levelIndexForEx.add(0);
      levelIndexForEx.add((maxLevel/2).ceil());
      levelIndexForEx.add(maxLevel);
    });


    // if(spu.hasSetMaxLevel){
    //   maxLevel = spu.maxLevel;
    // } else{
    //   maxLevel = 8;
    // }
    //
    // print("여기인건가?");

    mTimeStamp();

    // if(!didPassBetween){
    //   if(_connectionState == BluetoothConnectionState.disconnected){
    //     if(kDebugMode){
    //       print("[HomeScreen] The device is disconnected");
    //     }
    //     device.connectAndUpdateStream();
    //   }
    //   listeningToConnection();
    // }

    // msg.add("START!");

    print("끝");

    print("[HomeScreen] Done");
    super.initState();
  }

  // void listeningToConnection(){
  //   print("===== listeningToConnection() ======");
  //   _connectionStateSubscription = device.connectionState.listen((state) async {
  //     _connectionState = state;
  //
  //     switch(state){
  //       case BluetoothConnectionState.connected : _isConnected = true; break;
  //       case BluetoothConnectionState.disconnected: _isConnected = false; break;
  //       default: _isConnected = false; break;
  //     }
  //     if (state == BluetoothConnectionState.connected && _rssi == null) {
  //       _rssi = await device.readRssi();
  //     }
  //     if (mounted) {
  //       setState(() {});
  //     }
  //
  //     if(kDebugMode){
  //       print("[HomeScreen] listeningToConnection state: $state");
  //     }
  //
  //     if(state == BluetoothConnectionState.disconnected) {
  //       if (mounted) {
  //         setState(() {
  //           patchState = 0;
  //           battery = 0.0;
  //           batteryValue.value = 0;
  //           didInitialSet = false;
  //           level = -1;
  //           _numberExampleInput?.value = -1.0;
  //         });
  //       }
  //       updatingLevelIdx();
  //       device.connectAndUpdateStream();
  //       _lastValueSubscription.pause();
  //
  //       if(kDebugMode){
  //         print("[HomeScreen] patchState = $patchState");
  //         print("[HomeScreen] _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
  //       }
  //     }
  //     if(state == BluetoothConnectionState.connected){
  //       listeningToChar();
  //       _lastValueSubscription.resume();
  //       reConnect();
  //       setState(() {
  //         if(mounted){
  //           level = 0;
  //         }
  //       });
  //       updatingLevelIdx();
  //     }
  //   });
  // }
  //
  // void listeningToChar(){
  //   print("listeningToChar");
  //   service = context.read<BLEInfoProvider>().service;
  //
  //   if(kDebugMode){
  //     print("[HomeScreen] listeningToChar(): service uid is ${service.uuid.toString().toUpperCase()}");
  //   }
  //   characteristic = service.characteristics;
  //   if(kDebugMode){
  //     print("[HomeScreen] listeningToChar(): first element of char is ${characteristic[0].uuid.toString().toUpperCase()}");
  //   }
  //
  //   switch (characteristic.first.uuid.toString().toUpperCase()){
  //     case rx: idxTx = 1; idxRx = 0;
  //     if (kDebugMode) {
  //       print("rx = ${characteristic[idxRx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idxTx].uuid.toString().toUpperCase()}");
  //     }
  //     break;
  //     case tx: idxTx = 0; idxRx = 1;
  //     if (kDebugMode) {
  //       print("rx = ${characteristic[idxRx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idxTx].uuid.toString().toUpperCase()}");
  //     }
  //     break;
  //     default:
  //       if (kDebugMode) {
  //         print("characteristic doesn't match any");
  //       }
  //       Navigator.pop(context);
  //       break;
  //   }
  //
  //   device.discoverServices();
  //   if(kDebugMode){
  //     print("[HomeScreen] listeningToChar(): Before set notify value discover services");
  //   }
  //
  //   _lastValueSubscription = characteristic[idxTx].lastValueStream.listen((value) async {
  //     String convertedStr = utf8.decode(value).trimRight();
  //
  //     if(kDebugMode){
  //       print("[!!LastValueListen!!] listen string: $convertedStr");
  //     }
  //
  //     checking(convertedStr);
  //
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  //
  //   device.cancelWhenDisconnected(_lastValueSubscription);
  //
  //   characteristic[idxTx].setNotifyValue(true);
  //
  //   if (kDebugMode) {
  //     print("tx = ${characteristic[idxTx].uuid.toString().toUpperCase()}\nset notify");
  //   }
  //
  // }
  //
  // void checking(String msgString){
  //   if(kDebugMode){
  //     print("-------[HomeScreen] checking start-------");
  //     print("[HomeScreen] checking() current patch state: $patchState");
  //   }
  //
  //   if(msgString != ""){
  //     msg.add(msgString);
  //
  //     switch(patchState){
  //       case -1: {
  //         if(msgString.contains("Ready")){
  //           setState(() {
  //             patchState = 1;
  //           });
  //           write("Sn");
  //         }
  //         else{
  //           write("St");
  //           setState(() {
  //             patchState = 0;
  //           });
  //         }
  //       }
  //       break;
  //
  //       case 0: {
  //         if(msgString.contains("Ready")) {
  //           setState(() {
  //             patchState = 1;
  //           });
  //
  //           write("Sn");
  //
  //           if(kDebugMode){
  //             print("[HomeScreen] checking() : patchState $patchState");
  //           }
  //         }
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //       break; // Ready
  //
  //       case 1: {
  //         if(msgString.contains("Tn")){
  //           if(kDebugMode){
  //             print("[HomeScreen] checking() Tn: patchState $patchState");
  //           }
  //           String result = msg.last.replaceAll(RegExp(r'[^0-9]'), "");
  //           battery = double.parse(result);
  //           if(kDebugMode){
  //             print("Battery : $battery");
  //           }
  //           if(battery >= 4000.0){
  //             setState(() {
  //               battery = 1.0;
  //               batteryValue.value = battery * 100;
  //             });
  //           }else {
  //             setState(() {
  //               battery -= 3600.0;
  //               battery /= 400.0;
  //               batteryValue.value = battery * 100;
  //             });
  //           }
  //
  //           if(kDebugMode){
  //             print("Battery : $battery");
  //           }
  //
  //           if(!didInitialSet){
  //             if(kDebugMode){
  //               print("[HomeScreen] Checking didInitialSet: $didInitialSet");
  //             }
  //
  //             setState(() {
  //               patchState = 2;
  //             });
  //
  //             if (kDebugMode) {
  //               print("[HomeScreen] Checking set patchState: $patchState");
  //             }
  //             // write("Sm0, 100");
  //             write("status1");
  //           }
  //           else{
  //             if(kDebugMode){
  //               print("[HomeScreen] Checking didInitialSet: $didInitialSet");
  //             }
  //
  //             setState(() {
  //               patchState = 6;
  //             });
  //
  //             // TODO: 일단은 Home에서는 측정 기능만 있고 측정 때만 ble를 사용하기 때문에 그냥 Sj 여기에다 넣었는데 이후에 어떻게될지 모른다
  //             write("status1");
  //
  //             if (kDebugMode) {
  //               print("[HomeScreen] Checking set patchState: $patchState");
  //             }
  //           } // if - else: didInitialSet
  //         } // if: msgString.contains("Tn")
  //
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         } // else: msgString.contains("Tn")
  //       }
  //       break; // Sn
  //
  //       case 2:
  //         {
  //           if(msgString.contains("Return1")){
  //             setState(() {
  //               patchState = 3;
  //             });
  //             write("Sm0, 100");
  //           }
  //           else{
  //             setState(() {
  //               patchState = -1;
  //             });
  //           }
  //         }
  //         break; // status1
  //
  //       case 3:{
  //         if(msgString.contains("Tm0")){
  //           setState(() {
  //             patchState = 4;
  //           });
  //           write("Sl0, 5000");
  //         }
  //
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //       break; // Sm
  //
  //       case 4:{
  //         if(msgString.contains("Tl0")){
  //           setState(() {
  //             patchState = 5;
  //           });
  //           write("Sk0, 8");
  //         }
  //
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //       break; // Sl
  //
  //       case 5: {
  //         if(msgString.contains("Tk0")){
  //           setState(() {
  //             didInitialSet = true;
  //           });
  //           write("status0");
  //         }
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //       break; // Sk
  //
  //       case 6:{
  //         if(msgString.contains("Return1")){
  //           setState(() {
  //             patchState = 7;
  //           });
  //           if(areYouGoingToWrite) {
  //             //TODO: 여기서 온도 측정, 6축 센서 측정
  //             write("So");
  //           } else {
  //             write("status0");
  //           }
  //         }
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //       break;
  //
  //       case 7:{
  //         if(msgString.contains("To")){
  //           setState(() {
  //             timeStampForDBETC = DateFormat("yyyy/MM/dd/HH/mm/ss/SSS").format(DateTime.now()).toString();
  //             patchState = 8;
  //             msgString = msgString.replaceAll("To", "");
  //             temperature = double.parse(msgString.trim());
  //           });
  //           // TODO: timeStampForDBETC를 가지고 etc table에 temper 넣기
  //           print("To(temperature): $temperature");
  //           print("to TSDBETC: $timeStampForDBETC");
  //           ParsingTemperature(timeStampForDBETC, temperature);
  //
  //           /// TODO: temperature 이 벗어 나면
  //           /// write("status0"); patchState = 0; measuring = false; areYouGoingToWrite = false;
  //           write("Sp");
  //         }
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //
  //       case 8:{
  //         if(msgString.contains("Tp")){
  //           setState(() {
  //             patchState = 9;
  //           });
  //           msgString = msgString.replaceAll("Tp", "");
  //           print("tp TSDBETC: $timeStampForDBETC");
  //           ParsingAcGy(timeStampForDBETC, msgString);
  //           print("Sp(Gyro sensor): $msgString");
  //
  //           /// TODO: 여기서 Sj 전에 Tp 값이 오차 범위 내에 있는지 확인 후 Sj
  //           /// 만약 오차 범위를 벗어 나면
  //           /// write("status0"); patchState = 0; measuring = false; areYouGoingToWrite = false;
  //           write("Sj");
  //         }
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //
  //       }
  //
  //       case 9:{
  //         if(msgString.contains("Tj")){
  //           if(kDebugMode){
  //             print("[HomeScreen] checking() Tj: patchState $patchState");
  //           }
  //           tjmsg.add(msgString);
  //
  //           if(tjmsg.length % 24 == 0 && tjmsg.isNotEmpty){
  //
  //             timeStampForDBETC = DateFormat("yyyy/MM/dd/HH/mm/ss/SSS").format(DateTime.now()).toString();
  //
  //             ParsingMeasured(timeStampForDBETC, tjmsg);
  //             if(kDebugMode){
  //               print("[HOMESCREEN] PARSING DONE");
  //             }
  //             mTimeStamp();
  //             write("status0");
  //             setState(() {
  //               patchState = 0;
  //               measuring = false;
  //               areYouGoingToWrite = false;
  //             });
  //           }
  //         }
  //         else if(msgString.contains("Return0")){
  //           setState(() {
  //             patchState = 0;
  //           });
  //         }
  //         else{
  //           setState(() {
  //             patchState = -1;
  //           });
  //         }
  //       }
  //       break; // sj
  //
  //       default: patchState = -1; break;
  //     }
  //   }
  //
  //   if (kDebugMode) {
  //     int count = 0;
  //     print("value : $msgString");
  //     print("------------printing msg---------------");
  //     for(var element in msg){
  //       count++;
  //       print("$count : $element");
  //     }
  //     print("heard or listening");
  //   }
  // }
  //
  // Future write(String text) async {
  //   try {
  //     msg.add("[HomeScreen] write(): $text");
  //     text += "\r";
  //     // write하기 전에 device를 확인할 필요는 없을 것 같다
  //     // await device.connectAndUpdateStream();
  //     // if(kDebugMode){
  //     //   print("[HomeScreen] write() connectAndUpdateStream then");
  //     // }
  //     // init을 할 때 이미 event handler가 듣고 있음 (device 쪽이 listening)
  //
  //     await device.discoverServices();
  //     if(kDebugMode){
  //       print("[HomeScreen] write() discoverServices then");
  //     }
  //     await characteristic[idxRx].write(utf8.encode(text), withoutResponse: characteristic[idxRx].properties.writeWithoutResponse);
  //     if(kDebugMode){
  //       print("[HomeScreen] write() write characteristic[idxTx] then");
  //     }
  //
  //     if (kDebugMode) {
  //       print("[HomeScreen] wrote: $text");
  //       print("[HomeScreen] write() _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
  //     }
  //   } catch (e) {
  //     if(kDebugMode){
  //       print("[HomeScreen] wrote error\nError: $e");
  //     }
  //   }
  // }

  String timeStamp(){
    DateTime now = DateTime.now();
    String formattedTime = DateFormat.Hms().format(now);
    return formattedTime;
  }

  // Future reConnect() async{
  //   if(kDebugMode){
  //     print("[HomeScreen] reConnect() patch state: $patchState");
  //   }
  //   write("St");
  //   msg.add("Deny Buffer");
  //   return Future.delayed(const Duration(seconds: 1,));
  // }
  //
  // Future updateConnection() async{
  //   await device.connectAndUpdateStream();
  //   if(patchState == 0){
  //     reConnect();
  //   }
  // }
  //
  // Future updating() async{
  //   if(_isConnected){
  //     reConnect();
  //   }
  //   else{
  //     if(kDebugMode){
  //       print("Device is not connected");
  //     }
  //   }
  // }
  //
  // Future measure() async{
  //   setState(() {
  //     areYouGoingToWrite = true;
  //   });
  //   reConnect().then((value){
  //     // write("Sj");
  //   });
  // }

  void _riveOneInit(Artboard art){
    _stmController = StateMachineController.fromArtboard(art, 'State Machine 1') as StateMachineController;
    _stmController.isActive = true;
    art.addController(_stmController);
    _numberExampleInput = _stmController.findInput<double>('Number 1') as SMINumber;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      if(mounted){
        setState(() {
          _numberExampleInput?.value = riveIdx;
        });
      }
    });
  }

  List<TextStyle> cmtTitleStyle = [
    const TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green,
    ),
    const TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: Colors.orange,
    ),
    const TextStyle(
      fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red,
    ),
  ];

  List<String> cmt = [" to do your activities", " for your urination", "  do your catheterization",];
  TextStyle cmtStyle = const TextStyle(fontSize: 20, color: Colors.black,);

  void updatingLevelIdx(){
    if(_isConnected){
      if(level < maxLevel/2){
        setState(() {
          levelIdx = 0;
          riveIdx = levelIdx.toDouble();
          _numberExampleInput?.value = riveIdx;
        });
      }
      else if(level == (maxLevel/2).ceil()){
        setState(() {
          levelIdx = 1;
          riveIdx = levelIdx.toDouble();
          _numberExampleInput?.value = riveIdx;
        });
      }
      else if(level == -1){
        setState(() {
          levelIdx = 0;
          riveIdx = -1;
          _numberExampleInput?.value = riveIdx;
        });
      }
      else{
        setState(() {
          levelIdx = 2;
          riveIdx = levelIdx.toDouble();
          _numberExampleInput?.value = riveIdx;
        });
      }
    }
  }

  TextSpan checkingCmt(){
    if(level < maxLevel/2){
      return TextSpan(
        text: cmtTitle[0],
        style: cmtTitleStyle[0],
      );
    }
    else if(level == (maxLevel/2).ceil()){
      return TextSpan(
        text: cmtTitle[1],
        style: cmtTitleStyle[1],
      );
    }
    else if(level > 0){
      return TextSpan(
        text: cmtTitle[2],
        style: cmtTitleStyle[2],
      );
    }
    else{
      return TextSpan(
        text: cmtTitle[2],
        style: cmtTitleStyle[2],
      );
    }
  }

  void mTimeStamp() async{
    final model = DatabaseModel();
    var db = await model.timeStampGroupBy();

    measuredTime.clear();

    for(var item in db){
      setState(() {
        measuredTime.add(item.timeStamp);
      });
    }

    if(kDebugMode){
      print("-------------mTimeStamp---------------");
      for(var x in measuredTime){
        print(x);
      }
    }
  }

  String parseTimeStamp(String str){
    if(kDebugMode){
      print("[HomeScreen] parseTimeStamp str: $str");
    }
    var spStr = str.split("/");
    var finalStr = spStr[0];// year // TODO: 나중에는 Today's Measured로 바꿀거라 없어질 것임
    finalStr += "/";
    finalStr += spStr[1]; // month // TODO: 나중에는 Today's Measured로 바꿀거라 없어질 것임
    finalStr += "/";
    finalStr += spStr[2]; // day // TODO: 나중에는 Today's Measured로 바꿀거라 없어질 것임
    finalStr += "    [ ";
    finalStr += spStr[3]; // hour
    finalStr += ":";
    finalStr += spStr[4]; // min
    finalStr += ":";
    finalStr += spStr[5]; // sec
    finalStr += " ]";
    return finalStr;
  }

  void measureDemo() async{
    setState(() {
      measuring = true;
      print(measuring);
    });
    Future.delayed(const Duration(seconds: 1), (){
      setState(() {
        measuring = false;
        print(measuring);
      });
    });
  }

  String diffTime(String timeD){
    String resultStr;
    List<String> splitTimeD = timeD.split("/");
    String timeDToDateTime = "${splitTimeD[0]}-${splitTimeD[1]}-${splitTimeD[2]} ${splitTimeD[3]}:${splitTimeD[4]}:${splitTimeD[5]}";

    var timeDConvert = DateTime.parse(timeDToDateTime);
    Duration diff = current.difference(timeDConvert);
    resultStr = diff.toString().split('.').first.padLeft(8, "0");
    List<String> formatting = resultStr.split(":");
    resultStr = "";

    if(int.parse(formatting[0])>0) {
      resultStr += int.parse(formatting[0]).toString();
      resultStr += "hour";
    }
    if(int.parse(formatting[1])>0) {
      if(resultStr != "") resultStr += " ";
      resultStr += int.parse(formatting[1]).toString();
      resultStr += "min";
    }

    if(int.parse(formatting[0])==0 && int.parse(formatting[1])==0) {
      resultStr += "Currently";
    } else {
      resultStr += " Before";
    }

    return resultStr;
  }

  void goToBetweenScreen(){
    Navigator.pushReplacement(context, route);
  }

  @override
  void dispose() {
    super.dispose();
    // _connectionStateSubscription.cancel();
    // _lastValueSubscription.cancel();
    _stmController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return !didPassBetween?
    Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: Text(todayString, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Row(
          children: [
            Container(width: 20,),
            Image.asset("assets/logo.png", width: 80),
          ],
        ),
        leadingWidth: 100,
        actions: [
          InkWell(
            onTap: (){
              setState(() {
                _isConnected = !_isConnected;
                if(level != -1) {
                  level = -1;
                } else {
                  level = 0;
                }
                updatingLevelIdx();
                checkingCmt();
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5,),
                _isConnected? const Icon(Icons.link, size: 30,):const Icon(Icons.link_off, size: 30,),
                _isConnected? const Text("Linked", style: TextStyle(fontWeight: FontWeight.bold),):const Text("Unlinked", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          Container(width: 25,),
        ],
      ),
      body: PageStorage(
        bucket: pageBucket,
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: (){
                  setState(() {
                    levelCurrentIndexForEx++;
                    levelCurrentIndexForEx %= 3;
                    level = levelIndexForEx[levelCurrentIndexForEx];
                    updatingLevelIdx();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15,),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.41,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                      color: cardColors[levelIdx],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20,),
                        SizedBox(
                          width: w > 400? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.6,
                          child: Container(
                            height: h < 700? MediaQuery.of(context).size.height * 0.12 : MediaQuery.of(context).size.height * 0.09,
                            decoration: BoxDecoration(
                              color: _isConnected? Colors.black:Colors.redAccent,
                              borderRadius: const BorderRadius.all(Radius.circular(70)),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Spacer(flex: 1,),
                                // BatteryIndicator(
                                //   trackHeight: 17,
                                //   value: 0.9,
                                //   iconOutline: Colors.white,
                                // ),
                                _isConnected? const Icon(Icons.bolt_rounded, color: Colors.greenAccent, size: 30,) : const Icon(Icons.cancel, color: Colors.black, size: 30,),
                                const SizedBox(width: 10,),
                                _isConnected? const Text("MediLight", style: TextStyle(fontSize: 20, color: Colors.white),) :const Text("No Connection", style: TextStyle(fontSize: 20, color: Colors.white),),
                                _isConnected? const Spacer(flex: 2,) : const SizedBox(),
                                _isConnected?
                                SizedBox(
                                  width: 53,
                                  height: 53,
                                  child: SimpleCircularProgressBar(
                                    valueNotifier: batteryValue,
                                    progressStrokeWidth: 3,
                                    backStrokeWidth: 3,
                                    mergeMode: true,
                                    animationDuration: 0,
                                    onGetText: (double value){
                                      return Text("${value.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 20,),);
                                    },
                                  ),
                                ):
                                const SizedBox(),
                                const Spacer(flex: 1,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.06,),
                        // Center(child: Lottie.asset('assets/walking.json', frameRate: FrameRate.max, width: 250, height: 230,)),
                        SizedBox(
                          // color: Colors.purpleAccent,
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: RiveAnimation.asset(
                            "assets/rive/lil_guy_updated.riv",
                            fit: BoxFit.fitHeight,
                            onInit: _riveOneInit,
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.14,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    color: infoColors[levelIdx],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Center(child: Lottie.asset('assets/walking.json', frameRate: FrameRate.max, width: 250, height: 230,)),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0,),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Current", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                            const Spacer(flex: 1,),
                            Text("Lv. $level", style: const TextStyle(color: Color.fromRGBO(42, 77, 20, 1), fontSize: 20, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5),
                        child: LinearPercentIndicator(
                          animation: false,
                          animationDuration: 1000,
                          lineHeight: MediaQuery.of(context).size.height * 0.03,
                          percent: level >= 0? level/maxLevel : 0/maxLevel,
                          center: Text("Lv. $level", style: const TextStyle(fontSize: 15,),),
                          progressColor: const Color.fromRGBO(42, 77, 20, 1),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 5,),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Lv. $level", style: const TextStyle(color: Colors.white, fontSize: 17),),
                            const Spacer(flex: 1,),
                            Text("Lv. $maxLevel", style: const TextStyle(color: Colors.white, fontSize: 17),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20,),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: RichText(
                    text: TextSpan(
                      text: "Current Level: $level",
                      style: TextStyle(fontSize: 30, color: cmtColors[levelIdx]),
                      children: [
                        checkingCmt(),
                        level < maxLevel/2?
                        TextSpan(
                          text: cmt[0],
                          style: cmtStyle,
                        ) :
                        level == maxLevel/2?
                        TextSpan(
                          text: cmt[1],
                          style: cmtStyle,
                        ) :
                        TextSpan(
                          text: cmt[2],
                          style: cmtStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 30,),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: (){
                      measureDemo();
                      // if(_isConnected){
                      //   setState(() {
                      //     measuring = true;
                      //   });
                      //   // measure();
                      // }
                    },
                    child: const Text("Measure", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15,),
                child: Divider(),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10,),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Remaining catheter: $dayPer",
                      style: const TextStyle(color: Colors.white, fontSize: 20,),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 25, bottom: 10, top: 30,),
                child: Row(
                  children: [
                    Icon(Icons.book, size: 28,),
                    SizedBox(width: 5,),
                    Text("Measured Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  ],
                ),
              ),

              measuredTime.isEmpty?
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20,),
                child: Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.black54,
                    ),
                  ),
                  child: const Center(
                    child: Text("You haven't measure yet", style: TextStyle(fontSize: 18, color: Colors.black54),),
                  ),
                ),
              ):
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                  height: 60.0 * measuredTime.length,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 1,
                        color: Colors.black54,
                      )
                  ),
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: measuredTime.length,
                      itemBuilder: (BuildContext context, int index){
                        String parseString = parseTimeStamp(measuredTime[index]);
                        String diffStr = diffTime(measuredTime[index]);
                        return Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.77,
                                height: 23,
                                child: Text(parseString, style: const TextStyle(color: Colors.black, fontSize: 18,),),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.77,
                                height: 23,
                                child: Text(diffStr, style: const TextStyle(color: Colors.blue),),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

                  // const SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.only(left: 30, top: 30,),
                  //     child: Row(
                  //         Icon(Icons.auto_graph_rounded, size: 28,),
                  //         SizedBox(width: 5,),
                  //         Text("Measured Level", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // const SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: EdgeInsets.only(top: 10.0, bottom: 20,),
                  //     child: GraphWidget(),
                  //   ),
                  // ),

                  // SliverToBoxAdapter(  // 단일 위젯은 요걸로
                  //   child: Container(
                  //     height: 500.0,
                  //     color: Colors.blueGrey,
                  //     child: const Center(
                  //       child: Text("Some Start Widgets"),
                  //     ),
                  //   ),
                  // ),
                  Offstage(
                    offstage: !measuring,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Stack(
                        children: [
                          Opacity(
                            opacity: 0.5,
                            child: ModalBarrier(dismissible: false, color: Colors.black,),
                          ),
                          Center(child: CircularProgressIndicator(),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ):
    Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: 화질 구림
          Image.asset(
            "assets/lottie/skipBetween.gif",
            height: 300,
            width: 300,
          ),
          const SizedBox(height: 20,),
          const Text("No connected patch found", style: TextStyle(fontSize: 18),),
          const SizedBox(height: 40,),
          FilledButton(
            onPressed: (){
              goToBetweenScreen();
            },
            child: const Text("Reconnect", style: TextStyle(fontSize: 16,),),
          ),
        ],
      ),
    );
  }
}
