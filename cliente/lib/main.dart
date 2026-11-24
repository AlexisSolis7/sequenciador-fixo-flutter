import 'dart:convert';

import 'package:flutter/material.dart';

import 'services/conexao.dart';

// cores usadas na interface
const azul = Color(0xFF1E5BB8);
const azulClaro = Color(0xFFE3EDFB);
const verde = Color(0xFF2E9B4F);
const verdeClaro = Color(0xFFDDF5D6);
const fundo = Color(0xFFF3F5F8);
const borda = Color(0xFFD5DBE3);

const processos = ['P1', 'P2', 'P3'];

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sequenciador Fixo',
      theme: ThemeData(colorSchemeSeed: azul, scaffoldBackgroundColor: fundo),
      home: const TelaCliente(),
    );
  }
}

class TelaCliente extends StatefulWidget {
  const TelaCliente({super.key});

  @override
  State<TelaCliente> createState() => _TelaClienteState();
}

class _TelaClienteState extends State<TelaCliente> {
  String clienteSelecionado = 'P1';
  final List<MapEntry<int, String>> eventos = []; // eventos já entregues: número global -> id do evento
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
            eventos.add(MapEntry(proximoNumeroEsperado, idEventoPronto));
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
      appBar: AppBar(
        title: const Text('Sequenciador Fixo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: azul,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                barraSuperior(),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, restricoes) {
                    // tela larga: fluxo e etapas lado a lado; tela estreita: um embaixo do outro
                    if (restricoes.maxWidth > 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: cartaoFluxo()),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: cartaoEtapas()),
                        ],
                      );
                    }
                    return Column(children: [cartaoFluxo(), const SizedBox(height: 16), cartaoEtapas()]);
                  },
                ),
                const SizedBox(height: 16),
                cartaoEventos(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // barra com a escolha do cliente, conexão, status e o botão de gerar evento
  Widget barraSuperior() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              initialValue: clienteSelecionado,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: [
                for (final processo in processos)
                  DropdownMenuItem(value: processo, child: Text('Cliente $processo')),
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
          ),
          OutlinedButton(onPressed: conectado ? null : conectarAoServidor, child: const Text('Conectar')),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: conectado ? verde : Colors.red, size: 14),
              const SizedBox(width: 8),
              Text(textoStatus),
            ],
          ),
          FilledButton.icon(
            onPressed: rodadaPronta ? gerarEvento : null,
            style: FilledButton.styleFrom(backgroundColor: azul),
            icon: const Icon(Icons.add),
            label: const Text('Gerar evento'),
          ),
        ],
      ),
    );
  }

  // desenha o caminho do último evento: quem gerou -> sequenciador -> todos os clientes
  Widget cartaoFluxo() {
    if (eventos.isEmpty) {
      return cartao(
        titulo: 'Fluxo do último evento',
        conteudo: const Text(
          'Gere um evento para ver o caminho dele pelo sequenciador.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final numero = eventos.last.key;
    final idEvento = eventos.last.value;
    final remetente = idEvento.split(':').first; // 'P2:1' -> 'P2'

    return cartao(
      titulo: 'Fluxo do último evento',
      conteudo: Column(
        children: [
          // os três processos, com quem gerou o evento em destaque
          Row(
            children: [
              for (final processo in processos)
                Expanded(
                  child: caixa(
                    cor: processo == remetente ? azulClaro : Colors.white,
                    corBorda: processo == remetente ? azul : borda,
                    child: Center(
                      child: Text(
                        processo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: processo == remetente ? azul : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // seta só embaixo de quem enviou
          Row(
            children: [
              for (final processo in processos)
                Expanded(
                  child: Icon(Icons.arrow_downward, color: processo == remetente ? azul : Colors.transparent),
                ),
            ],
          ),
          caixa(
            cor: azulClaro,
            corBorda: azul,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sequenciador fixo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: azul),
                ),
                const SizedBox(height: 4),
                Text('Recebeu $idEvento sem ordem'),
                Text('Contador global: ${numero - 1} → $numero'),
                Text('Ordem atribuída: #$numero', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // o sequenciador envia o mesmo evento numerado para todos
          const Row(
            children: [
              Expanded(child: Icon(Icons.arrow_downward, color: verde)),
              Expanded(child: Icon(Icons.arrow_downward, color: verde)),
              Expanded(child: Icon(Icons.arrow_downward, color: verde)),
            ],
          ),
          Row(
            children: [
              for (final processo in processos)
                Expanded(
                  child: caixa(
                    child: Center(
                      child: Column(
                        children: [
                          Text('Enviado para $processo', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '#$numero $idEvento',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: verde),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // as quatro etapas do algoritmo, preenchidas com o último evento
  Widget cartaoEtapas() {
    final List<String> etapas;
    if (eventos.isEmpty) {
      etapas = const ['Um cliente gera um evento', 'Sequenciador recebe', 'Atribui a ordem global', 'Distribui para todos'];
    } else {
      final numero = eventos.last.key;
      final idEvento = eventos.last.value;
      final remetente = idEvento.split(':').first;
      etapas = ['$remetente gerou $idEvento', 'Sequenciador recebeu', 'Atribuiu a ordem #$numero', 'Distribuiu para todos'];
    }

    return cartao(
      titulo: 'Etapas',
      conteudo: Column(
        children: [
          for (var i = 0; i < etapas.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: borda),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: azulClaro,
                    child: Text('${i + 1}', style: const TextStyle(color: azul, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(etapas[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // tabela com os eventos na ordem global; o último fica destacado em verde
  Widget cartaoEventos() {
    return cartao(
      titulo: 'Eventos ordenados',
      conteudo: eventos.isEmpty
          ? const Text('Nenhum evento recebido.', style: TextStyle(color: Colors.black54))
          : Column(
              children: [
                linhaTabela('Ordem global', 'Evento', corFundo: fundo),
                for (final evento in eventos)
                  evento == eventos.last
                      ? linhaTabela('#${evento.key}', evento.value, corFundo: verdeClaro, corTexto: verde)
                      : linhaTabela('#${evento.key}', evento.value, negrito: false),
              ],
            ),
    );
  }

  Widget linhaTabela(
    String ordem,
    String evento, {
    Color corFundo = Colors.white,
    Color corTexto = Colors.black87,
    bool negrito = true,
  }) {
    final estilo = TextStyle(color: corTexto, fontWeight: negrito ? FontWeight.bold : FontWeight.normal);
    return Container(
      color: corFundo,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(ordem, style: estilo)),
          Expanded(flex: 2, child: Text(evento, style: estilo)),
        ],
      ),
    );
  }

  // cartão branco com título, usado nas três partes da tela
  Widget cartao({required String titulo, required Widget conteudo}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borda),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: fundo,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          Padding(padding: const EdgeInsets.all(16), child: conteudo),
        ],
      ),
    );
  }

  // caixa com borda arredondada usada no desenho do fluxo
  Widget caixa({required Widget child, Color cor = Colors.white, Color corBorda = borda}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cor,
        border: Border.all(color: corBorda, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
