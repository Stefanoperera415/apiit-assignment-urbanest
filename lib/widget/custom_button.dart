import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonName;
  final Color buttonNameColor;
  final Color buttonColor;
  final double borderRadiusButton;
  final Color borderColor;
  //width of the button border
  //font size of the text


  const CustomButton({
    super.key,
    required this.buttonName,
    required this.buttonColor,
    required this.borderRadiusButton,
    required this.borderColor, 
    required this.buttonNameColor, 

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadiusButton),
        color: buttonColor,
        border: Border.all(
          color: borderColor,
          width: 4
        ),
      ),

      child: Center(child: Text(buttonName
        ,style: TextStyle(
          color: buttonNameColor,
          fontSize: 16,
          fontWeight: FontWeight.w500
        ),
      )),
    );
  }
}
