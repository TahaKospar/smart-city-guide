import 'package:flutter/material.dart';

class Inputtext extends StatefulWidget {
  final String? hintText;
  final bool isPassword;
  final TextInputType? type;
  final String? isIcon;
  final TextEditingController? myController;
  final String? Function(String?)? validator;

  const Inputtext({
    super.key,
    required this.hintText,
    required this.isPassword,
    required this.myController,
    this.type,
    this.isIcon,
    this.validator,
  });

  @override
  State<Inputtext> createState() => _InputtextState();
}

class _InputtextState extends State<Inputtext> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (val) {
        if (val!.isEmpty) {
          return "Can't be empty";
        }
      },
      obscureText: widget.isPassword ? _obscure : false,
      controller: widget.myController,
      keyboardType: widget.type,
      decoration: InputDecoration(
        filled: true,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
                icon: Icon(
                  _obscure ? Icons.visibility_sharp : Icons.visibility_off,
                ),
              )
            : null,
        fillColor: Colors.grey[300],
        hintText: "${widget.hintText}",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(120)),
      ),
    );
  }
}
