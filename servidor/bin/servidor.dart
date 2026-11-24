import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final servidor = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  ); //InternetAddress.loopbackIPv4 representa o 127.0.0.1 signfica o proprio computador

  print('Servidor iniciado em ws://127.0.0.1:8080/ws');

  final clientes = <String, WebSocket>{};
  final identificadoresPermitidos = {'P1', 'P2', 'P3'};

  int proximoNumeroGlobal = 1;

  await for (final requisicao in servidor) {
    // para cada requisicao que chegar pelo servidor, execute o bloco

    final caminhoCorreto = requisicao.uri.path == '/ws'; // só para confirmar se no final tem o /ws
    final pediuWebSocket = WebSocketTransformer.isUpgradeRequest(requisicao); // é um bool
    //isUpgradeRequest = é um dedido de mudança? ao inves de http um websocket;; ele verifica o cabeçalho se tem o upgrade:websocket
    if (caminhoCorreto && pediuWebSocket) {
      final cliente = await WebSocketTransformer.upgrade(requisicao);
      String? identificadorRegistrado;

      print('Cliente conectado');

      cliente.listen(
        (mensagem) {
          final dados = jsonDecode(mensagem) as Map<String, dynamic>;

          final tipo = dados['tipo'];
          final identificador = dados['cliente'];

          if (tipo == 'evento') {
            final idEvento = dados['idEvento'];

            final numeroGlobal = proximoNumeroGlobal; //incrementamos o numeroGlobal mas antes guardamos em numeroGlobal que representa esse momento
            proximoNumeroGlobal++;

            final eventoOrdenado = jsonEncode({
              //odenando para enviar aos clientes depois
              'tipo': 'evento_ordenado',
              'numeroGlobal': numeroGlobal,
              'cliente': identificador,
              'idEvento': idEvento,
            });

            for (final clienteConectado in clientes.values) {
              //enviamos o json para todos os clientes
              clienteConectado.add(eventoOrdenado);
            }

            print('Evento global $numeroGlobal: $idEvento recebido de $identificador');

            return;
          }

          if (tipo != 'registro' || identificador is! String) {
            cliente.add(jsonEncode({'tipo': 'erro', 'mensagem': 'Mensagem de registro inválida'}));
            return;
          }

          if (!identificadoresPermitidos.contains(identificador)) {
            cliente.add(jsonEncode({'tipo': 'erro', 'mensagem': 'Identificador inválido'}));
            return;
          }

          if (clientes.containsKey(identificador)) {
            //O mapa já possui esse identificador como chave?
            cliente.add(jsonEncode({'tipo': 'erro', 'mensagem': '$identificador já está conectado'}));
            return;
          }

          clientes[identificador] = cliente;
          identificadorRegistrado = identificador;

          cliente.add(jsonEncode({'tipo': 'registro_ok', 'cliente': identificador}));

          print('$identificador registrado');
          if (clientes.length == 3) {
            final aviso = jsonEncode({'tipo': 'rodada_pronta'});

            for (final clienteConectado in clientes.values) {
              clienteConectado.add(aviso);
            }

            print('Os três clientes estão conectados. Rodada pronta!');
          }
        },
        onDone: () {
          if (identificadorRegistrado != null) {
            clientes.remove(identificadorRegistrado);
            print('$identificadorRegistrado desconectado');
          }
        },
      );
    } else {
      requisicao.response.statusCode = HttpStatus.badRequest;
      requisicao.response.write('Use o endereço WebSocket /ws');
      await requisicao.response.close();
    }
  }
}
