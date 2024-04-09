import 'package:ble_uart/widgets/register_form_field.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image(image: const AssetImage('assets/logo300.png'), height: MediaQuery.of(context).size.height * 0.2,),
                  const RegisterFormField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

