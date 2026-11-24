import 'package:flutter/material.dart';

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
                onChanged: (novoCliente) {
                  if (novoCliente != null) {
                    setState(() {
                      clienteSelecionado = novoCliente;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: Colors.red, size: 14),
                  SizedBox(width: 8),
                  Text('Desconectado', style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(onPressed: null, icon: const Icon(Icons.add), label: const Text('Gerar evento')),
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
                          return ListTile(leading: Text('${indice + 1}'), title: Text(eventos[indice]));
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
