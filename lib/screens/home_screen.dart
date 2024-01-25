import 'dart:async';
import 'dart:convert';

import 'package:ble_uart/screens/between_screen.dart';
import 'package:ble_uart/screens/uart_screen.dart';
import 'package:ble_uart/utils/ble_info.dart';
import 'package:ble_uart/utils/extra.dart';
import 'package:cupertino_battery_indicator/cupertino_battery_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const String rx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // write data to the rx characteristic to send it to the UART interface.
  static const String tx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Enable notifications for the tx characteristic to receive data from the application.

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<List<int>> _lastValueSubscription;

  late BluetoothDevice device;
  late BluetoothService service;
  late List<BluetoothCharacteristic> characteristic;

  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  late Route route = MaterialPageRoute(builder: (context) => const BetweenScreen());

  bool _isConnected = false;
  int? _rssi;

  int idx_tx = 1;
  int idx_rx = 0;

  List<String> msg = [];

  int patchState = 0;
  double battery = 0.0;

  String todayString = "";
  int read = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(kDebugMode){
      print("[HomeScreen] !!Init state start!!");
      print("[HomeScreen] patch state is $patchState");
    }

    todayString = DateFormat.yMMMd().format(DateTime.now());

    device = context.read<BLEInfo>().device;
    service = context.read<BLEInfo>().service;
    characteristic = service.characteristics;

    msg.clear();

    // msg.add("START!");

    _connectionStateSubscription = device.connectionState.listen((state) async {
      _connectionState = state;
      if(kDebugMode){
        print("[HomeScreen] initState() state: $state");
      }
      if(state == BluetoothConnectionState.disconnected){
        setState(() {
          patchState = -1;
          battery = 0.0;
        });
        _lastValueSubscription.pause();
        device.connectAndUpdateStream();
        if(kDebugMode){
          print("[HomeScreen] patchState = $patchState");
          print("[HomeScreen] _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
        }
      }
      if(state == BluetoothConnectionState.connected){
        if(kDebugMode){
          print("-------[HomeScreen] _connectionState listeningToChar()-------");
        }
        listeningToChar();
        if(kDebugMode){
          print("-------[HomeScreen] _connectionState listeningToChar() done-------");
        }
        if(kDebugMode){
          print("-------[HomeScreen] _connectionState _lastValueSubscription.resume-------");
        }
        _lastValueSubscription.resume();
        if(kDebugMode){
          print("-------[HomeScreen] _connectionState _lastValueSubscription.resume done-------");
        }
        if(kDebugMode){
          print("-------[HomeScreen] _connectionState reConnect()-------");
        }
        reConnect();
        if(kDebugMode){
          print("-------[HomeScreen] _connectionState reConnect() done-------");
        }
        if(kDebugMode){
          print("[HomeScreen] _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
        }
      }
      switch(state){
        case BluetoothConnectionState.connected : _isConnected = true; break;
        case BluetoothConnectionState.disconnected: _isConnected = false; break;
        default: _isConnected = false; break;
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void listeningToChar(){
    service = context.read<BLEInfo>().service;
    if(kDebugMode){
      print("[HomeScreen] listeningToChar(): service uid is ${service.uuid.toString().toUpperCase()}");
    }
    characteristic = service.characteristics;
    if(kDebugMode){
      print("[HomeScreen] listeningToChar(): first element of char is ${characteristic[0].uuid.toString().toUpperCase()}");
    }

    switch (characteristic.first.uuid.toString().toUpperCase()){
      case rx: idx_tx = 1; idx_rx = 0;
      if (kDebugMode) {
        print("rx = ${characteristic[idx_rx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idx_tx].uuid.toString().toUpperCase()}");
      }
      break;
      case tx: idx_tx = 0; idx_rx = 1;
      if (kDebugMode) {
        print("rx = ${characteristic[idx_rx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idx_tx].uuid.toString().toUpperCase()}");
      }
      break;
      default:
        if (kDebugMode) {
          print("characteristic doesn't match any");
        }
        Navigator.pop(context);
        break;
    }

    device.discoverServices();
    if(kDebugMode){
      print("[HomeScreen] listeningToChar(): Before set notify value discover services");
    }
    characteristic[idx_tx].setNotifyValue(true);
    if (kDebugMode) {
      print("tx = ${characteristic[idx_tx].uuid.toString().toUpperCase()}\nset notify");
    }

    _lastValueSubscription = characteristic[idx_tx].lastValueStream.listen((value) async {
      String convertedStr = utf8.decode(value).trimRight();

      if(kDebugMode){
        print("[!!LastValueListen!!] listen string: $convertedStr");
      }

      checking(convertedStr);

      if (mounted) {
        setState(() {});
      }
    });


  }

  void checking(String msgString){
    if(kDebugMode){
      print("-------[HomeScreen] checking start-------");
      print("[HomeScreen] checking() current patch state: $patchState");
    }

    if(msgString != ""){
      msg.add(msgString);

      if(patchState == 0){
        if(msgString.contains("Ready")) {
          setState(() {
            patchState = 1;
          });

          write("Sn");

          if(kDebugMode){
            print("[HomeScreen] checking() : patchState $patchState");
          }
        } else {
          setState(() {
            patchState = -1;
          });

          if(kDebugMode){
            print("[HomeScreen] checking() : patchState $patchState");
            print("[HomeScreen] checking() : msg is $msgString");
          }
        }
      }

      if(patchState == -1){
        if(kDebugMode){
          print("[HomeScreen] patch state should be -1: $patchState");
        }
        if(msgString.contains("Ready")){
          setState(() {
            patchState = 1;
            write("Sn");
            // checking(msgString);
          });
        }
        else{
          msg.add("[HomeScreen] patch is -1 (STILL CONNECTED NOT DISCONNECTED)\nSo the last value will not return the St\nWrite St begins now");
          // write("St");
        }
      }

      if(patchState == 1 && msgString.contains("Tn")){
        if(kDebugMode){
          print("[HomeScreen] checking() Tn: patchState $patchState");
        }
          String result = msg.last.replaceAll(RegExp(r'[^0-9]'), "");
          battery = double.parse(result);
          if(kDebugMode){
            print("Battery : $battery");
          }
          battery -= 3600.0;
          battery /= 400.0;

          if(kDebugMode){
            print("Battery : $battery");
          }

          setState(() {
            patchState = 0;
            if(kDebugMode){
              print("[HomeScreen] checking()-Tn: patch state should be 0: $patchState");
            }
          });

          if(mounted){
            setState(() {

            });
          }
        }
      }

    if (kDebugMode) {
      int count = 0;
      print("value : $msgString");
      print("------------printing msg---------------");
      for(var element in msg){
        count++;
        print("$count : $element");
      }
      print("heard or listening");
    }
  }

  Future write(String text) async {
    try {
      // TODO : _textCnt.text cmd 확인 절차
      msg.add("[HomeScreen] write(): $text");
      text += "\r";
      // write하기 전에 device를 확인할 필요는 없을 것 같다
      // await device.connectAndUpdateStream();
      // if(kDebugMode){
      //   print("[HomeScreen] write() connectAndUpdateStream then");
      // }
      // init을 할 때 이미 event handler가 듣고 있음 (device 쪽이 listening)

      await device.discoverServices();
      if(kDebugMode){
        print("[HomeScreen] write() discoverServices then");
      }
      await characteristic[idx_rx].write(utf8.encode(text), withoutResponse: characteristic[idx_rx].properties.writeWithoutResponse);
      if(kDebugMode){
        print("[HomeScreen] write() write characteristic[idx_tx] then");
      }

      if (kDebugMode) {
        print("[HomeScreen] wrote: $text");
        print("[HomeScreen] write() _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
      }
    } catch (e) {
      if(kDebugMode){
        print("[HomeScreen] wrote error\nError: $e");
      }
    }
  }

  String timeStamp(){
    DateTime now = DateTime.now();
    String formattedTime = DateFormat.Hms().format(now);
    return formattedTime;
  }

  Future reConnect() async{
    if(kDebugMode){
      print("[HomeScreen] reConnect() patch state: $patchState");
    }
    write("St");
    return Future.delayed(const Duration(seconds: 1,));
  }

  Future updateConnection() async{
    await device.connectAndUpdateStream();
    if(patchState == 0){
      reConnect();
    }
  }

  Future updating() async{
    if(_isConnected){
      reConnect();
    }
    else{
      if(kDebugMode){
        print("Device is not connected");
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _connectionStateSubscription.cancel();
    _lastValueSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(todayString, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
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
            onTap: (){},
            child: Column(
              children: [
                _isConnected? const Icon(Icons.link, size: 30,):const Icon(Icons.link_off, size: 30,),
                _isConnected? const Text("Linked", style: TextStyle(fontWeight: FontWeight.bold),):const Text("Unlinked", style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          Container(width: 25,),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: updating,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(  // 단일 위젯은 요걸로
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 15, right: 15,),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.42,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: const Color.fromRGBO(178, 212, 182, 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Lottie.asset('assets/lottie/walking.json', frameRate: FrameRate.max, width: 250, height: 230,)),
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 15,),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Current", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                                  Spacer(flex: 1,),
                                  Text("Lv. 3", style: TextStyle(color: Color.fromRGBO(42, 77, 20, 1), fontSize: 20, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 0.0, top: 5),
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width * 0.82,
                                animation: false,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                percent: 0.375,
                                center: const Text("Lv. 3", style: TextStyle(fontSize: 13,),),
                                progressColor: const Color.fromRGBO(42, 77, 20, 1),
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 5,),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Lv. 0", style: TextStyle(color: Colors.white, fontSize: 17),),
                                  Spacer(flex: 1,),
                                  Text("Lv. 8", style: TextStyle(color: Colors.white, fontSize: 17),),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 22,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 30,),
                                child: BatteryIndicator(
                                  trackHeight: 17,
                                  value: battery,
                                  iconOutline: Colors.white,
                                ),
                              ),
                              Container(width: 10,),
                              Text("${(battery*100).round()}%", style: const TextStyle(fontSize: 16,),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SliverAppBar(
                    backgroundColor: Colors.white,
                    scrolledUnderElevation: 0.0,
                    elevation: 0.0,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.12,
                    collapsedHeight: MediaQuery.of(context).size.height * 0.08,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 30.0, top: 10.0, right: 0.0, bottom: 15.0),
                      title: RichText(
                        text: const TextSpan(
                          text: "Current Level: 3",
                          style: TextStyle(fontSize: 15, color: Colors.green),
                          children: [
                            TextSpan(
                              text: "\nFREE",
                              style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green,
                              ),
                            ),
                            TextSpan(
                              text: " to do your activities",
                              style: TextStyle(
                                fontSize: 15, color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      centerTitle: false,
                    ),
                  ),

                  SliverToBoxAdapter(  // 단일 위젯은 요걸로
                    child: Container(
                      height: 500.0,
                      color: Colors.white,
                      child: const Center(
                        child: Text("Some Start Widgets"),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(  // 단일 위젯은 요걸로
                    child: Container(
                      height: 500.0,
                      color: Colors.blueGrey,
                      child: const Center(
                        child: Text("Some Start Widgets"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
