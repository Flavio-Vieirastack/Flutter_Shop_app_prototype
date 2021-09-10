import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:olx_App/models/Anuncio.dart';
import 'package:url_launcher/url_launcher.dart';


class DetalhesAnuncio extends StatefulWidget {

  Anuncio anuncio;

  DetalhesAnuncio(this.anuncio);

  @override
  _DetalhesAnuncioState createState() => _DetalhesAnuncioState();
}

class _DetalhesAnuncioState extends State<DetalhesAnuncio> {

  Anuncio _anuncio;

  List<Widget> _getListaImagens() {
    
    List<String> listaUrlImagem = _anuncio.fotos;
    return listaUrlImagem.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(url),
            fit: BoxFit.fitWidth
          )
        ),
      );
    }).toList();
  }

  _ligarTelefone(String telefone) async {
    if (await canLaunch("tel:$telefone")) {
      await launch("tel:$telefone");
    } else {
      print("nao pode fazer a ligação");
    }
  }

  @override
  void initState() {
    super.initState();

    _anuncio = widget.anuncio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Anuncio")),
      body: Stack(
        children: [
          //conteudos
          ListView(
            children: [
              SizedBox(
                height: 250,
                child: Carousel(
                  images: _getListaImagens(),
                  dotSize: 8,
                  dotBgColor: Colors.transparent,
                  dotColor: Colors.white,
                  autoplay: false,
                  dotIncreasedColor: Color(0xff9c27b0),
                ),
              ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "R\$ ${_anuncio.preco}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9c27b0)

                    ),
                  ),

                  Text(
                    "${_anuncio.titulo}",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,

                    ),
                  ),

                  Padding(padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                  ),

                Text(
                    "Descrição",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                    ),
                  ),

                Text(
                    "${_anuncio.descricao}",
                    style: TextStyle(
                      fontSize: 18,

                    ),
                  ),

                  Padding(padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                  ),

                Text(
                    "Contato",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                    ),
                  ),

                Padding(
                  padding: EdgeInsets.only(bottom: 66),
                  child: Text(
                    "${_anuncio.telefone}",
                    style: TextStyle(
                      fontSize: 18,

                    ),
                  ),
                  )

                ],
              ),
            )
            ],
          ),
          //botao ligar
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: GestureDetector(
              child: Container(
                child: Text(
                  "Ligar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
                  ),
                padding: EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 5)
                    )
                  ],
                  color: Color(0xff9c27b0),
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
              onTap: (){
                _ligarTelefone(_anuncio.telefone);
              },
            )
            )
        ],
      ),
    );
  }
}
