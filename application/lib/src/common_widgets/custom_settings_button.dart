import 'package:flutter/material.dart';

import '../utils/global_variables.dart';

class CustomSettingsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool centerText;

  const CustomSettingsButton(
      {super.key, required this.text, this.onPressed, this.centerText = false});

  @override
  Widget build(BuildContext context) {
    Widget child = centerText
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                text,
                style: GlobalVariables.textStyle2,
              ),
            ),
          )
        : Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  text,
                  style: GlobalVariables.textStyle2,
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.arrow_forward_ios_rounded),
              ),
            ],
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: MediaQuery.of(context).size.width - 40.0,
      height: 50.0,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: onPressed,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
