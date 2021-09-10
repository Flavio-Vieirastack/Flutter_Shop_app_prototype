import 'package:flutter/material.dart';
import 'package:olx_App/Routegenerator.dart';
import 'package:olx_App/view/Anuncios.dart';



void main() {

  final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff9c27b0),
    accentColor: Color(0xff7b1fa2)
  );

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "My ShopApp",
    home: Anuncios(),
    theme: temaPadrao,
    debugShowCheckedModeBanner: false,
    onGenerateRoute: RouteGenerator.generateroute,
    initialRoute: "/",
  ));
}
