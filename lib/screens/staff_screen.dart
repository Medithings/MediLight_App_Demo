import 'package:ble_uart/screens/ai_screen.dart';
import 'package:ble_uart/screens/threshold_setting_screen.dart';
import 'package:ble_uart/screens/uart_screen.dart';
import 'package:ble_uart/utils/shared_prefs_utils.dart';
import 'package:ble_uart/widgets/account_settings_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/settings_tile.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {

  final spu = SharedPrefsUtil();
  late int maxLevel;

  @override
  void initState() {
    // TODO: implement initState
    if(spu.hasSetMaxLevel){
      maxLevel = spu.maxLevel;
    }
    else{
      maxLevel = 8;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Staff Mode"),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SettingsTile(stIcon: Icons.info, title: "UART MODE", goto: UARTScreen(), bgColor: Colors.blueAccent,),
          const SizedBox(height: 10,),
          const SettingsTile(stIcon: Icons.rocket, title: "AI Re-training", goto: AIScreen(), bgColor: Colors.red,),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ThresholdSettingScreen())).then((_) => setState((){maxLevel = spu.maxLevel;}));
            },
            child: AccountSettingsTile(
                stIcon: Icons.settings,
                title: "Set threshold",
                bgColor: Colors.grey,
                info: spu.hasSetMaxLevel? "$maxLevel" : "Not set yet"),
          ),
        ],
      ),
    );
  }
}
