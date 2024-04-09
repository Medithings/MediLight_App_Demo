import 'package:ble_uart/versions//patient_ver/passcode_screen.dart';
import 'package:ble_uart/versions//patient_ver/patch_info_screen.dart';
import 'package:ble_uart/widgets/settings_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences pref;
  String name = "";

  @override
  void initState() {
    prefGetter();
    // TODO: implement initState
    super.initState();
  }

  void prefGetter() async {
    pref = await SharedPreferences.getInstance();

    try{
      setState(() {
        name = pref.getString("name")!;
      });
    }catch(e){
      if (kDebugMode) {
        print("error : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(225, 225, 225, 0.3),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.13,
            child: const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  child: Padding(
                    padding: EdgeInsets.only(left: 40.0,),
                    child: Text("Settings", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,),),
                  ),
                ),
            ),
          ),
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color.fromRGBO(225, 225, 225, 1),),
                bottom: BorderSide(color: Color.fromRGBO(225, 225, 225, 1),),
              ),
            ),
            child: InkWell(
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const AccountScreen(),),),
              child: Row(
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent),
                          color: Colors.black12,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: const Icon(Icons.person, color: Colors.black38, size: 30,),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 25,),),
                      const Text("Account Settings", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15,),),
                    ],
                  ),
                  const Spacer(flex: 1,),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black38, size: 15,),
                  const SizedBox(width: 10,),
                ],
              ),
            ),
          ),
          SizedBox(height: 20,),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color.fromRGBO(225, 225, 225, 1),),
                      )
                  ),
                  child: const SettingsTile(stIcon: Icons.info, title: "Patch info", goto: PatchInfoScreen(), bgColor: Colors.blueAccent,),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 56.0),
                  child: Divider(color: Color.fromRGBO(225, 225, 225, 1), height: 1,),
                ),
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color.fromRGBO(225, 225, 225, 1),),
                      )
                  ),
                  child: const SettingsTile(stIcon: Icons.accessibility, title: "STAFF MODE", goto: PasscodeScreen(), bgColor: Colors.red,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
