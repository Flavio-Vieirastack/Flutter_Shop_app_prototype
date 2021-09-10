import 'package:flutter/material.dart';
import 'package:olx_App/view/Anuncios.dart';
import 'package:olx_App/view/DetalhesAnuncio.dart';
import 'package:olx_App/view/Loguin.dart';
import 'package:olx_App/view/MeusAnuncios.dart';
import 'package:olx_App/view/NovoAnuncio.dart';

class RouteGenerator {
  static Route<dynamic> generateroute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Anuncios());

      case "/loguin":
        return MaterialPageRoute(builder: (_) => Loguin());

      case "/meus-anuncios":
        return MaterialPageRoute(builder: (_) => MeusAnuncios());

      case "/novo-anuncio":
        return MaterialPageRoute(builder: (_) => NovoAnuncio());

      case "/detalhes-anuncio":
        return MaterialPageRoute(builder: (_) => DetalhesAnuncio(args));

      default:
        _erroRota();
    }
    return null;
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada"),
        ),
        body: Center(
          child: Image.asset("images/erro.jpg"),
        ),
      );
    });
  }
}
