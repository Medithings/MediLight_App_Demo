import 'package:ble_uart/screens/patient_ver/staff_screen.dart';
import 'package:flutter/material.dart';

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key});

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  late bool first, second, third, fourth;
  List<int> passkey = [];
  late bool correct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    first = false;
    second = false;
    third = false;
    fourth = false;
    correct = true;
  }

  void checking(int item){
    if(passkey.length < 4){
      passkey.add(item);
    }

    switch (passkey.length){
      case 0:
        setState(() {
          first = false;
          second = false;
          third = false;
          fourth = false;
        });
        break;
      case 1:
        setState(() {
          first = true;
          second = false;
          third = false;
          fourth = false;
          correct = true;
        });
        break;
      case 2:
        setState(() {
          first = true;
          second = true;
          third = false;
          fourth = false;
        });
        break;
      case 3:
        setState(() {
          first = true;
          second = true;
          third = true;
          fourth = false;
        });
        break;
      case 4:
        setState(() {
          first = true;
          second = true;
          third = true;
          fourth = true;
        });
        break;
      default:
        setState(() {
          first = false;
          second = false;
          third = false;
          fourth = false;
        });
        break;
    }

    if(passkey.length == 4){
      if(passkey[0] == 2 && passkey[1] == 5 && passkey[2] == 8 && passkey[3] == 0){
        setState(() {
          correct = true;
          first = false;
          second = false;
          third = false;
          fourth = false;
        });
        passkey.clear();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StaffScreen()));
      }
      else{
        setState(() {
          correct = false;
          first = false;
          second = false;
          third = false;
          fourth = false;
        });
        passkey.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    const Spacer(flex: 1,),
                    IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded, size: 30, color: Colors.black,),
                    ),
                    const SizedBox(width: 10,),
                  ],
                ),
              ),
              const SizedBox(height: 50,),
              const Text("Enter your passcode", style: TextStyle(fontSize: 25,),),
              const SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 5,),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: first? const Text("*", style: TextStyle(fontSize: 50, color: Colors.black),) : Container(),
                    ),
                  ),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: second? const Text("*", style: TextStyle(fontSize: 50, color: Colors.black),) : Container(),
                    ),
                  ),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: third? const Text("*", style: TextStyle(fontSize: 50, color: Colors.black),) : Container(),
                    ),
                  ),
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: fourth? const Text("*", style: TextStyle(fontSize: 50, color: Colors.black),) : Container(),
                    ),
                  ),
                  const SizedBox(width: 5,),
                ],
              ),
              const SizedBox(height: 10,),
              // Text("$passkey / ${passkey.length}"),
              correct? Container() : Text("Wrong passcode", style: TextStyle(fontSize: 15, color: Colors.red),),
              const Spacer(flex: 1,),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(1);
                        },
                        child: const Text("1", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(2);
                        },
                        child: const Text("2", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(3);
                        },
                        child: const Text("3", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(4);
                        },
                        child: const Text("4", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(5);
                        },
                        child: const Text("5", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(6);
                        },
                        child: const Text("6", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(7);
                        },
                        child: const Text("7", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(8);
                        },
                        child: const Text("8", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(9);
                        },
                        child: const Text("9", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: (){},
                        child: const Text("", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: (){
                          checking(0);
                        },
                        child: const Text("0", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.w300),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 7.5, left: 7.5),
                        child: IconButton(
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: (){
                            setState(() {
                              if(passkey.isNotEmpty) passkey.length--;
                              if(passkey.isEmpty){
                                setState(() {
                                  first = false;
                                  second = false;
                                  third = false;
                                  fourth = false;
                                });
                              }
                              if(passkey.length == 1){
                                setState(() {
                                  first = true;
                                  second = false;
                                  third = false;
                                  fourth = false;
                                });
                              }
                              if(passkey.length == 2){
                                setState(() {
                                  first = true;
                                  second = true;
                                  third = false;
                                  fourth = false;
                                });
                              }
                              if(passkey.length == 3){
                                setState(() {
                                  first = true;
                                  second = true;
                                  third = true;
                                  fourth = false;
                                });
                              }
                              if(passkey.length == 4){
                                setState(() {
                                  first = true;
                                  second = true;
                                  third = true;
                                  fourth = true;
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.backspace_outlined, size: 28,),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
