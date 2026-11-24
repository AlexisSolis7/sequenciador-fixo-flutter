import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class Conexao {
  WebSocketChannel? _canal; // WebSocketChannel representa a conexão aberta entre cliente e servidor.

  Stream<dynamic>? get mensagens {
    // o stream quer dizer que vai chegar um fluxo de mgs e o dnamico e que pode vir qualquer tipo
    if (_canal == null) {
      return null;
    }
    return _canal!.stream; // o stream sao as mensagens que chegam do servidor
  }

  // asyn para que possamos usar o await
  Future<void> conectar(String cliente) async {
    // o futere basicamente e como dizer: Esta função terminará no futuro, mas não devolverá nenhum valor
    final canal = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8080/ws'));

    await canal.ready;
    _canal = canal;

    enviar({'tipo': 'registro', 'cliente': cliente});
  }

  void enviar(Map<String, dynamic> dados) {
    _canal?.sink.add(jsonEncode(dados)); // transforma o mapa de texto em json
  } // o sink envia e add adiciona esse json

  Future<void> desconectar() async {
    await _canal?.sink.close();
    _canal = null;
  }
}
