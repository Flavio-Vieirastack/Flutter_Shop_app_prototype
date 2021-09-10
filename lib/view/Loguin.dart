import 'package:flutter/material.dart';
import 'package:olx_App/models/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx_App/view/widgets/InputCustomizado.dart';

import 'widgets/BotaoCustomizado.dart';

class Loguin extends StatefulWidget {
  @override
  _LoguinState createState() => _LoguinState();
}

class _LoguinState extends State<Loguin> {
  TextEditingController _controllerEmail =
      TextEditingController(text: "flavio@gmail.com");
  TextEditingController _controllerSenha =
      TextEditingController(text: "1234567");

  bool _cadastrar = false;

  String _mensagemErro = "";
  String _textoBotao = "Entrar";

  _cadastrarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      //redirecionar para a tela principal
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      //redirecionar para a tela principal
      Navigator.pushReplacementNamed(context, "/");
    });
  }

  _validarCampos() {
    //recuperar dados dos campos
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains("@")) {
      //validação de email

      if (senha.isNotEmpty && senha.length > 6) {
        //configurar usuario
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        if (_cadastrar == true) {
          //cadastrar
          _cadastrarUsuario(usuario);
        } else {
          //logar
          _logarUsuario(usuario);
        }
      } else {
        //else senha
        setState(() {
          _mensagemErro = "A senha deve conter mais de 6 caracteres";
        });
      }
    } else {
      //else email
      setState(() {
        _mensagemErro = "Preencha um Email válido";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/lock.png",
                    width: 200,
                    height: 150,
                  ),
                ),

                InputCustomizado(
                  controller: _controllerEmail,
                  hint: "Email",
                  autofocus: true,
                  type: TextInputType.emailAddress,
                ),

                InputCustomizado(
                  controller: _controllerSenha,
                  hint: "Senha",
                  maxLines: 1,
                  obscure: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Logar"),
                    Switch(
                        value: _cadastrar,
                        onChanged: (bool valor) {
                          setState(() {
                            _cadastrar = valor;
                            _textoBotao = "Entrar";
                            if (_cadastrar == true) {
                              _textoBotao = "Cadastrar";
                            }
                          });
                        }),
                    Text("Cadastrar"),
                  ],
                ),
                
                BotaoCustomizado(
                    texto: _textoBotao,
                    onpressed: () {
                      _validarCampos();
                    }),
      
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(_mensagemErro,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
