import 'dart:async';
import 'dart:io';
import 'package:ble_uart/versions/patient_ver/ai_screen.dart';
import 'package:ble_uart/utils/ble_info_provider.dart';
import 'package:ble_uart/utils/extra.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/scan_result_tile.dart';

class FirstConnectScreen extends StatefulWidget {
  const FirstConnectScreen({super.key});

  @override
  State<FirstConnectScreen> createState() => _FirstConnectScreenState();
}

class _FirstConnectScreenState extends State<FirstConnectScreen> {

  final Route route = MaterialPageRoute(builder: (context) => const AIScreen());
  late SharedPreferences pref;

  bool scanBool = false;



  @override
  void initState() {
    super.initState();
    getPref();
  }

  void getPref() async{
    pref = await SharedPreferences.getInstance();
  }

  // @override
  // void didChangeDependencies(){
  //   super.didChangeDependencies();
  //   onScan();
  //
  //   _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) { // Scan result 를 listen
  //     // before : _scanResults = results
  //
  //     // after : 이름에 Bladder 또는 Medi가 있을 때 Scan result에 저장
  //     _scanResults.clear();
  //
  //     for (var element in results) {
  //       if(element.device.platformName.contains("Bladder") || element.device.platformName.contains("MEDi")){
  //         if(_scanResults.indexWhere((x) => x.device.remoteId == element.device.remoteId) < 0){
  //           _scanResults.add(element);
  //           pref.setString("patchName", element.device.platformName);
  //         }
  //       }
  //     }
  //
  //     if (mounted) { // mounted 가 true 일 때 setState 를 해주는 것이 올바름
  //       setState(() {}); // set state
  //     }
  //
  //   }, onError: (e) { // 에러 발생 시
  //     if(kDebugMode){
  //       print("[FirstConnectScreen] something went wrong while scanning on the initial state\nError: $e");
  //     }
  //   });
  //
  //   _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) { // is scanning 을 listen
  //     _isScanning = state; // listen 해서 받아온 state 를 _isScanning 에 복사
  //     if (mounted) { // mounted?
  //       setState(() {}); // set state
  //     }
  //   });
  // }

  @override
  void dispose() { // dispose 하면 모든 subscription (listen 하는 것) 중지
    // _scanResultsSubscription.cancel();
    // _isScanningSubscription.cancel();
    super.dispose();
  }

  // Future onScan() async { // Scan button pressed
  //   try {
  //   } catch (e) {
  //     if(kDebugMode){
  //       print("[FirstConnectScreen] something went wrong while onScan-systemDevices is done\nError: $e");
  //     }
  //   }
  //   try {
  //     // android is slow when asking for all advertisements,
  //     // so instead we only ask for 1/8 of them
  //     int divisor = Platform.isAndroid ? 8 : 1;
  //     _scanResults.clear();
  //     await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5), continuousUpdates: true, continuousDivisor: divisor);
  //   } catch (e) {
  //     if(kDebugMode){
  //       print("[FirstConnectScreen] something went wrong while onScan-startScan is done\nError: $e");
  //     }
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // Future onStopPressed() async {
  //   try {
  //     FlutterBluePlus.stopScan();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("[FirstConnectScreen] something went wrong while onStopPressed-stopScan is done\nError: $e");
  //     }
  //   }
  // }
  //
  // void onConnectPressed(BluetoothDevice device) async{
  //   try{
  //     await device.connectAndUpdateStream();
  //     if (kDebugMode) {
  //       print("[FirstConnectScreen] onConnectPressed - device: ${device.platformName}");
  //     }
  //     storingDevice(device);
  //     setSPRemoteId(device.remoteId.str);
  //   }catch(e){
  //     if (kDebugMode) {
  //       print("[FirstConnectScreen] something went wrong while onConnectPressed-connectAndUpdateStream is done\nError: $e");
  //     }
  //   }

    // try{
    //   await device.connect(mtu: null, autoConnect: true);
    // }catch(e){
    //   if (kDebugMode) {
    //     print("[FirstConnectScreen] something went wrong while onConnectPressed-connect is done\nError: $e");
    //   }
    // }
  //
  //   try{
  //     for(var element in await device.discoverServices()){
  //       if(element.uuid.toString().toUpperCase() == suid){
  //         _services.add(element);
  //         storingService(element);
  //       }
  //     }
  //     if(kDebugMode){
  //       print("[FirstConnectScreen] onConnectPressed - service uuid : ${_services.first.uuid.toString().toUpperCase()}");
  //     }
  //   }catch(e){
  //     if(kDebugMode){
  //       print("[FirstConnectScreen] something went wrong while onConnectPressed-discoverService is done\nError: $e");
  //     }
  //   }
  //
  //   // TODO: device_screen에서 함수 불러오고 shared preferences의 registered를 true
  //   route = MaterialPageRoute(builder: (context) => const AIScreen());
  //
  //   // pref = await SharedPreferences.getInstance();
  //   // pref.setBool('registered', true);
  //   Future.delayed(Duration.zero,(){
  //     goAI();
  //   });
  // }

  // void storingService(BluetoothService s){
  //   context.read<BLEInfoProvider>().service = s;
  // }
  //
  // void storingDevice(BluetoothDevice d){
  //   context.read<BLEInfoProvider>().device = d;
  // }

  void goAI(){
     Navigator.pushReplacement(context, route);
  }

  // Future setSPRemoteId(String remoteId) async{
  //   pref.setString('remoteId', remoteId);
  //   if(kDebugMode){
  //     print("[FirstConnectScreen] remoteId: $remoteId saved");
  //   }
  // }

  // Widget buildScanButton(BuildContext context) {
  //   if (FlutterBluePlus.isScanningNow) {
  //     return FloatingActionButton(
  //       onPressed: onStopPressed,
  //       backgroundColor: Colors.red,
  //       child: const Icon(Icons.stop),
  //     );
  //   } else {
  //     return FloatingActionButton(
  //       onPressed: onScan,
  //       child: const Text("SCAN"),
  //     );
  //   }
  // }

  Widget buildScanButton(BuildContext context) {
    if (scanBool) {
      return FloatingActionButton(
        onPressed: () {
          setState(() async {
            await Future.delayed(const Duration(seconds: 2), (){
              setState(() {
                scanBool = false;
              });
            });
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: (){
          setState(() {
            scanBool = true;
          });
        },
        child: const Text("SCAN"),
      );
    }
  }

  // Future onRefresh() {
  //   if (_isScanning == false) {
  //     FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  //   return Future.delayed(const Duration(milliseconds: 500));
  // }

  // List<Widget> _buildScanResultTiles(BuildContext context) {
  //   return _scanResults
  //       .map(
  //         (r) => ScanResultTile(
  //       result: r,
  //       onTap: () => goAI,
  //     ),
  //   )
  //       .toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Devices'),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
      ),
      body: ListView(
        children: <Widget>[
          // no need system devices
          // ..._buildSystemDeviceTiles(context),
          // ..._buildScanResultTiles(context),
          const SizedBox(height: 50,),
          InkWell(
            onTap: (){
              Navigator.pushReplacement(context, route);
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 30,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 50,),
                  Text("Bladder 01", style: TextStyle(fontSize: 15,),),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: buildScanButton(context),
    );
  }
}
