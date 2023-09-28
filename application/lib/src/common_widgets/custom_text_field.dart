import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/global_variables.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextFieldType textFieldType;
  final bool read;
  final String? errorMessage;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.textFieldType = TextFieldType.normal,
    this.read = false,
    this.errorMessage,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = false;
  IconData? prefixIcon;
  IconData? suffixIcon;

  @override
  void initState() {
    super.initState();

    switch (widget.textFieldType) {
      case TextFieldType.date:
        prefixIcon = Icons.calendar_today;
        suffixIcon = Icons.clear;
        break;
      case TextFieldType.email:
        prefixIcon = Icons.email_outlined;
        break;
      case TextFieldType.password:
        prefixIcon = Icons.lock_outline;
        suffixIcon = Icons.visibility_outlined;
        obscureText = true;
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextFormField(
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        controller: widget.controller,
        readOnly: widget.textFieldType == TextFieldType.date || widget.read,
        minLines: widget.textFieldType == TextFieldType.area ? 6 : null,
        maxLines: widget.textFieldType == TextFieldType.area ? null : 1,
        onTap: widget.textFieldType == TextFieldType.date && !widget.read
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 50),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: GlobalVariables.textFieldColor2,
                            onPrimary: Colors.white,
                            onSurface: GlobalVariables.fontColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: GlobalVariables.textFieldColor2,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    });

                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  widget.controller.text = formattedDate;
                }
              }
            : null,
        decoration: InputDecoration(
          prefixIcon: widget.textFieldType == TextFieldType.date ||
                  widget.textFieldType == TextFieldType.email ||
                  widget.textFieldType == TextFieldType.password
              ? Icon(
                  prefixIcon,
                  color: GlobalVariables.textFieldColor2,
                )
              : null,
          suffixIcon: (widget.textFieldType == TextFieldType.date ||
                      widget.textFieldType == TextFieldType.password) &&
                  !widget.read
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: GlobalVariables.textFieldColor2,
                  ),
                  onPressed: () {
                    if (widget.textFieldType == TextFieldType.date) {
                      widget.controller.text = '';
                    } else {
                      setState(() {
                        obscureText = !obscureText;
                        if (obscureText) {
                          suffixIcon = Icons.visibility_outlined;
                        } else {
                          suffixIcon = Icons.visibility_off_outlined;
                        }
                      });
                    }
                  },
                )
              : null,
          labelText: widget.label,
          labelStyle: const TextStyle(
            color: GlobalVariables.textFieldColor1,
          ),
          floatingLabelStyle: const TextStyle(
            color: GlobalVariables.textFieldColor2,
          ),
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
                color: GlobalVariables.textFieldColor2, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
                color: GlobalVariables.textFieldColor1, width: 1.0),
          ),
          errorText: widget.errorMessage,
        ),
      ),
    );
  }
}
