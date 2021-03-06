import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final List<TextInputFormatter> inputFormatrers;
  final int maxLines;
  final Function(String) validator;
  final Function(String) onSaved;

  const InputCustomizado(
      {
      @required this.controller,
      @required this.hint,
      this.obscure = false,
      this.autofocus = false,
      this.type = TextInputType.text,
      this.inputFormatrers,
      this.maxLines,
      this.validator,
      this.onSaved
      });

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      controller: this.controller,
      autofocus: this.autofocus,
      obscureText: this.obscure,
      keyboardType: this.type,
      inputFormatters: this.inputFormatrers,
      maxLines: this.maxLines,
      validator: this.validator,
      onSaved: this.onSaved,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: this.hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
    );
  }
}
