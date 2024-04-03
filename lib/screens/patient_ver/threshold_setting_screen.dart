import 'package:ble_uart/utils/shared_prefs_utils.dart';
import 'package:flutter/material.dart';

const List<Widget> levels = <Widget>[
  Text("Lv. 3", style: TextStyle(fontSize: 20),),
  Text("Lv. 4", style: TextStyle(fontSize: 20),),
  Text("Lv. 5", style: TextStyle(fontSize: 20),),
  Text("Lv. 6", style: TextStyle(fontSize: 20),),
  Text("Lv. 7", style: TextStyle(fontSize: 20),),
  Text("Lv. 8", style: TextStyle(fontSize: 20),),
];

class ThresholdSettingScreen extends StatefulWidget {
  const ThresholdSettingScreen({super.key});

  @override
  State<ThresholdSettingScreen> createState() => _ThresholdSettingScreenState();
}

class _ThresholdSettingScreenState extends State<ThresholdSettingScreen> {
  final spu = SharedPrefsUtil();

  final List<bool> _selectedLevels = <bool>[false, false, false, false, false, false];

  @override
  void initState() {
    // TODO: implement initState
    if(spu.hasSetMaxLevel){
      _selectedLevels[spu.maxLevel - 3] = true;
    }
    else{
      _selectedLevels.last = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Threshold"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ToggleButtons(
                direction: Axis.vertical,
                onPressed: (int index){
                  setState(() {
                    for(int i=0; i<_selectedLevels.length; i++){
                      _selectedLevels[i] = i == index;
                    }
                    spu.maxLevel = index + 3;
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.blue[700],
                selectedColor: Colors.white,
                fillColor: Colors.blue[200],
                color: Colors.blue[400],
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.106,
                  minWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                isSelected: _selectedLevels,
                children: levels,
              ),
                
              const SizedBox(height: 50,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 80,
                child: FilledButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(const Color(0xffB3C8CF)),
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: const Text("Ok", style: TextStyle(fontSize: 25,),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
