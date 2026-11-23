# Sequenciador fixo

Neste trabalho de Sistemas Distribuídos, vou implementar uma demonstração simples do algoritmo de sequenciador fixo. O servidor será feito em Dart e os três clientes serão uma aplicação Flutter Web.

Escolhi a versão Web para não precisar instalar o Visual Studio nem gerar um executável para Windows. O VS Code também não é obrigatório: posso editar os arquivos com qualquer editor e executar o projeto pelo terminal. Para testar a aplicação, vou usar o navegador.

## Situação atual

Já criei o projeto Flutter do cliente com suporte à Web. Neste momento, ele ainda mostra a tela de contador criada automaticamente pelo Flutter. Os arquivos específicos do sequenciador e do servidor ainda serão implementados.

## Como vai funcionar

Vou usar um servidor como sequenciador e três clientes, identificados como P1, P2 e P3. O servidor será executado no terminal. O cliente será aberto em três abas ou janelas do navegador, e cada uma terá sua própria conexão com o servidor.

Antes de entrar, vou escolher um identificador disponível para o cliente. O servidor não permitirá dois clientes com o mesmo identificador.

Ao clicar em **Gerar evento**, o cliente vai criar automaticamente um evento, como `P2:1`, e enviá-lo ao servidor. O sequenciador vai atribuir um número global e distribuir o evento para os três clientes, inclusive para quem o gerou. Cada cliente vai exibir os eventos seguindo essa numeração.

```text
P1 ─┐
P2 ─┼──> sequenciador ──> P1, P2 e P3
P3 ─┘        1, 2, 3...
```

Por exemplo, se os pedidos de P2 e P1 chegarem nessa ordem ao servidor, o resultado poderá ser:

```text
1 — Evento de P2
2 — Evento de P1
```

O importante não é o instante exato do clique, mas que todos os clientes recebam e mostrem a mesma ordem definida pelo sequenciador.

## Comunicação e interface

Como o cliente será executado no navegador, vou usar **WebSocket** em vez de um socket TCP direto. A conexão continuará sendo cliente-servidor e bidirecional, mas será compatível com Flutter Web.

As mensagens serão objetos JSON. Cada mensagem do WebSocket transportará um objeto completo, portanto não será necessário separar as mensagens por quebra de linha.

Inicialmente, tudo será executado no mesmo computador:

- cliente Flutter Web aberto no navegador;
- servidor Dart disponível em `ws://127.0.0.1:8080/ws`;
- três conexões WebSocket independentes, uma para P1, uma para P2 e uma para P3.

A interface será simples e terá:

- seleção do identificador P1, P2 ou P3;
- estado da conexão;
- botão **Gerar evento**;
- lista ordenada dos eventos recebidos.

A lógica interna manterá o próximo número esperado e um pequeno buffer. Assim, um evento só aparecerá na lista quando todos os números anteriores já tiverem sido entregues.

Na primeira versão, os três clientes deverão estar conectados antes de gerar eventos. Se um cliente desconectar durante a rodada, o servidor avisará os demais e a rodada será reiniciada. Não vou implementar recuperação automática, banco de dados ou troca de sequenciador.

## Estrutura

```text
servidor/
  bin/servidor.dart
  lib/protocolo.dart
  lib/sequenciador.dart
  test/sequenciador_test.dart
  pubspec.yaml
cliente/
  web/
  lib/main.dart
  lib/models/evento.dart
  lib/services/conexao.dart
  lib/controllers/cliente_controller.dart
  lib/screens/cliente_screen.dart
  test/ordenacao_test.dart
  pubspec.yaml
docs/imagens/
```

## Etapas de desenvolvimento

### Parte 1 — Preparar o Flutter Web

Esta parte já foi feita. O projeto Flutter foi criado e a pasta `cliente/web/` está disponível. Antes de continuar, vou apenas confirmar no terminal se Chrome ou Edge aparece no comando:

```powershell
flutter devices
```

Não preciso corrigir avisos sobre Visual Studio ou Android Studio, pois o alvo deste projeto é somente a Web.

### Parte 2 — Criar a interface básica

Vou substituir a tela de contador por uma tela com seleção de P1, P2 ou P3, botão de conexão, estado da conexão, botão **Gerar evento** e lista inicialmente vazia.

Nesta parte ainda não haverá comunicação real. O objetivo será apenas deixar a interface pronta e fácil de entender.

### Parte 3 — Criar o servidor WebSocket

Vou configurar o projeto Dart dentro de `servidor/` e criar um servidor HTTP local que aceite conexões WebSocket no caminho `/ws`.

O servidor vai registrar os clientes conectados, aceitar somente P1, P2 e P3 e rejeitar identificadores repetidos. Quando os três estiverem conectados, ele avisará que a rodada pode começar.

### Parte 4 — Conectar o Flutter ao servidor

Vou adicionar ao cliente uma biblioteca compatível com WebSocket e conectar a interface ao endereço `ws://127.0.0.1:8080/ws`.

Depois disso, vou testar uma aba de cada vez: conectar P1, P2 e P3 e conferir os registros no terminal do servidor.

### Parte 5 — Implementar o sequenciamento

Cada cliente terá um contador local para criar eventos como `P1:1` e `P1:2`. Quando o servidor receber um pedido, vai incrementar seu contador global, criar a mensagem ordenada e enviá-la aos três clientes.

O servidor será o único responsável por escolher os números globais. Os clientes não poderão inventar nem alterar essa numeração.

### Parte 6 — Implementar a entrega ordenada

Cada cliente vai guardar os eventos recebidos pelo número global. Se o próximo número esperado estiver disponível, ele será mostrado; caso contrário, ficará no buffer até a chegada dos anteriores.

Essa parte vai garantir que P1, P2 e P3 mostrem listas iguais.

### Parte 7 — Tratar o encerramento da rodada

Vou desabilitar o botão enquanto os três clientes não estiverem conectados. Se uma aba for fechada durante o teste, o servidor notificará as outras e bloqueará novos eventos até o início de uma nova rodada.

### Parte 8 — Testar e documentar

Vou abrir o cliente em três abas ou janelas, escolher P1, P2 e P3 e gerar vários eventos. No final, vou comparar as listas e confirmar que:

- todos receberam os mesmos eventos;
- a ordem é igual nos três clientes;
- não existem números globais repetidos ou pulados;
- um identificador repetido é recusado;
- a queda de um cliente encerra a rodada de forma visível.

Também vou completar este README com os comandos finais, resultados, capturas de tela e trechos importantes do código.

## Execução prevista

O servidor será iniciado em um terminal:

```powershell
cd servidor
dart pub get
dart run bin/servidor.dart
```

O cliente será iniciado em outro terminal:

```powershell
cd cliente
flutter pub get
flutter run -d chrome --web-port=3000
```

Depois, vou abrir `http://localhost:3000` em três abas ou janelas e identificar cada uma como P1, P2 e P3.

## Relatório e apresentação

Na apresentação, quero mostrar o terminal do sequenciador e os três clientes no navegador. Vou gerar eventos em diferentes clientes e comparar as listas. Também vou explicar a principal limitação do algoritmo: como existe um sequenciador único, se ele parar, novos eventos deixam de ser ordenados.
