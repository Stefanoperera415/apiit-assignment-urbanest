import 'package:flutter/material.dart';


class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
  
      children: [
        Image.asset("assets/images/Urbanest.png",
        
        height: 120,
        fit: BoxFit.cover,
        ),     
        Center(
          child: 
            Column(
              children: [
                Text("Urbanest",
                  style: TextStyle(
                    fontSize: 60,
                    color: Colors.black,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.center,
                ),
              
              ],
            ),
        )
      ],
    );
  }
}