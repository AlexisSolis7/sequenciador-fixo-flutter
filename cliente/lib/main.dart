import 'dart:convert';

import 'package:flutter/material.dart';

import 'services/conexao.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: TelaCliente());
  }
}

class TelaCliente extends StatefulWidget {
  const TelaCliente({super.key});

  @override
  State<TelaCliente> createState() => _TelaClienteState();
}

class _TelaClienteState extends State<TelaCliente> {
  String clienteSelecionado = 'P1';
  final List<String> eventos = [];
  final Conexao conexao = Conexao();
  bool conectado = false;

  bool rodadaPronta = false;
  int proximoEventoLocal = 1;
  String textoStatus = 'Desconectado';
  int proximoNumeroEsperado = 1;
  final Map<int, String> bufferEventos = {}; // vai guarda os eventos pelo número global

  Future<void> conectarAoServidor() async {
    try {
      await conexao.conectar(clienteSelecionado);
    } catch (_) {
      // o servidor não está rodando ou não respondeu
      setState(() {
        textoStatus = 'Servidor indisponível';
      });
      return;
    }

    conexao.mensagens?.listen((mensagem) {
      final dados = jsonDecode(mensagem);

      if (dados['tipo'] == 'registro_ok') {
        setState(() {
          conectado = true;
          textoStatus = 'Conectado como ${dados['cliente']}';
        });
      } else if (dados['tipo'] == 'rodada_pronta') {
        setState(() {
          rodadaPronta = true;
          textoStatus = 'Os três clientes estão conectados';
        });
      } else if (dados['tipo'] == 'erro') {
        setState(() {
          textoStatus = dados['mensagem'];
        });
      } else if (dados['tipo'] == 'evento_ordenado') {
        final numeroGlobal = dados['numeroGlobal'];
        final idEvento = dados['idEvento'];
        setState(() {
          bufferEventos[numeroGlobal] = idEvento;

          while (bufferEventos.containsKey(proximoNumeroEsperado)) {
            // basicamente ele percorre o buffer e containsKey=contem essa chave?
            final idEventoPronto = bufferEventos.remove(proximoNumeroEsperado)!;
            eventos.add('$proximoNumeroEsperado — $idEventoPronto');
            proximoNumeroEsperado++;
          }
        });
      }
    });
  }

  void gerarEvento() {
    final idEvento = '$clienteSelecionado:$proximoEventoLocal'; // exemplo: idEvento = 'P2:1'; e depois no proximo clique: idEvento = 'P2:2';

    conexao.enviar({'tipo': 'evento', 'cliente': clienteSelecionado, 'idEvento': idEvento});

    proximoEventoLocal++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sequenciador Fixo'), foregroundColor: Colors.black),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: clienteSelecionado,
                decoration: const InputDecoration(labelText: 'Escolha o cliente', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'P1', child: Text('P1')),
                  DropdownMenuItem(value: 'P2', child: Text('P2')),
                  DropdownMenuItem(value: 'P3', child: Text('P3')),
                ],
                onChanged: conectado
                    ? null
                    : (novoCliente) {
                        if (novoCliente != null) {
                          setState(() {
                            clienteSelecionado = novoCliente;
                          });
                        }
                      },
              ),
              const SizedBox(height: 20),

              ElevatedButton(onPressed: conectado ? null : conectarAoServidor, child: const Text('Conectar')),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: conectado ? Colors.green : Colors.red, size: 14),
                  SizedBox(width: 8),
                  Text(textoStatus, style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(onPressed: rodadaPronta ? gerarEvento : null, icon: const Icon(Icons.add), label: const Text('Gerar evento')),
              const Divider(height: 40),

              const Text(
                'Eventos ordenados',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 180,
                child: eventos.isEmpty
                    ? const Center(
                        child: Text('Nenhum evento recebido.', style: TextStyle(color: Colors.black54)),
                      )
                    : ListView.builder(
                        itemCount: eventos.length, //quantidade de linhas ou eventos como vc quiser dizer
                        itemBuilder: (context, indice) {
                          //aqui ele constroi a lista basicamente
                          return ListTile(title: Text(eventos[indice]));
                        }, //leading e o conteudo inicial da linha
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
