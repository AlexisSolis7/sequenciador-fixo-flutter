# Sequenciador fixo
Trabalho de Sistemas Distribuídos sobre o algoritmo de sequenciador fixo. Fizemos o servidor em Dart e os clientes em Flutter Web para conseguir executar tudo de forma simples no navegador.

## Como funciona

Usamos três clientes, identificados como P1, P2 e P3, e um servidor que funciona como sequenciador.

Quando alguém clica em **Gerar evento**, o cliente cria um identificador como `P2:1` e envia ao servidor. O sequenciador atribui o próximo número global e distribui o resultado para todos.

```text
P2 envia P2:1 sem ordem
Sequenciador atribui o número global 4
P1, P2 e P3 recebem #4 P2:1
```

Cada cliente possui um pequeno buffer para garantir que os eventos sejam mostrados na ordem correta, sem pular números.

## O que já está pronto

- interface para escolher P1, P2 ou P3;
- conexão cliente-servidor por WebSocket;
- bloqueio de identificadores repetidos;
- botão para gerar eventos;
- contador local em cada cliente;
- contador global no sequenciador;
- distribuição para os três clientes;
- lista e buffer de eventos ordenados.

O servidor usa `ws://127.0.0.1:8080/ws` e as mensagens são enviadas em JSON.

## Como executar

Primeiro inicio o servidor:

```powershell
cd servidor
dart pub get
dart run bin/servidor.dart
```

Em outro terminal, inicio o cliente:

```powershell
cd cliente
flutter pub get
flutter run -d chrome --web-port=3000
```

Depois abro `http://localhost:3000` em três abas e conecto uma como P1, outra como P2 e outra como P3.
