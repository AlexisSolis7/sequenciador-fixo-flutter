# Sequenciador fixo

Neste trabalho de Sistemas Distribuídos, vou implementar uma demonstração simples do sequenciador fixo usando Dart e Flutter para Windows. Cada cliente terá um botão para gerar um evento, e todos vão mostrar os eventos na mesma ordem definida pelo servidor.

Por enquanto, deixei apenas a estrutura das pastas e os arquivos vazios. O projeto ainda não executa; vou preencher o código e as configurações nas próximas etapas.

## Como vai funcionar

Vou usar um servidor como sequenciador e três clientes, identificados como P1, P2 e P3. O servidor será um programa Dart no terminal. Vou abrir três instâncias do mesmo aplicativo Flutter, uma para cada cliente.

Ao clicar em **Gerar evento**, o cliente vai criar automaticamente um evento identificado, como `P2:1`, e enviar ao servidor. O sequenciador vai atribuir um número global e distribuir o evento para os três clientes, inclusive para quem o gerou. Cada cliente vai registrar o evento na lista seguindo essa numeração, sem pular posições.

```text
P1, P2 e P3 → sequenciador → eventos numerados para P1, P2 e P3
```

Por exemplo, se eu clicar primeiro em P2 e depois em P1, o servidor poderá ordenar `1 — Evento de P2` e `2 — Evento de P1`. O que importa é que todos entreguem a ordem atribuída pelo sequenciador; cliques quase simultâneos podem chegar ao servidor em outra ordem.

## Comunicação e interface

Vou fazer a comunicação por TCP, com mensagens JSON separadas por quebra de linha. O pedido vai identificar o evento; a distribuição também vai informar a origem e o número global de sequência. Inicialmente, vou executar tudo no mesmo computador, usando o endereço `127.0.0.1` e a porta `5000`.

Vou deixar a interface com o identificador do cliente, um botão **Gerar evento** e uma lista com o número de sequência e a origem dos eventos entregues. Também vou mostrar o estado da conexão. A ordenação e o buffer ficarão na lógica do programa, sem painéis extras na primeira versão.

Na primeira versão, vou conectar os três clientes antes de começar. Se alguém desconectar, vou encerrar a rodada e reiniciar os processos. Não vou implementar recuperação automática nessa etapa.

## Estrutura

```text
servidor/
  bin/servidor.dart
  lib/protocolo.dart
  lib/sequenciador.dart
  test/sequenciador_test.dart
  pubspec.yaml
cliente/
  lib/main.dart
  lib/models/evento.dart
  lib/services/conexao.dart
  lib/controllers/cliente_controller.dart
  lib/screens/cliente_screen.dart
  test/ordenacao_test.dart
  pubspec.yaml
docs/imagens/
```

## Desenvolvimento e execução

Vou precisar do Flutter com suporte a Windows e do Dart. Ainda vou configurar os arquivos `pubspec.yaml`, as dependências e os arquivos de suporte do aplicativo Windows. Depois vou registrar aqui as versões usadas e os comandos exatos para instalar e executar.

Vou desenvolver primeiro o servidor e a troca de mensagens, depois a ordenação nos clientes e a interface. Para testar, vou gerar eventos pelos três participantes, inclusive com cliques próximos, e conferir se as listas ficam iguais e os números não se repetem.

## Relatório e apresentação

Vou completar este README com os procedimentos de instalação, configuração e execução, os resultados dos testes e imagens da interface. Também vou incluir trechos do código mostrando a identificação dos processos, o envio, a recepção e a ordenação das mensagens.

Na apresentação, quero mostrar os quatro processos funcionando, gerar eventos nos três clientes e comparar suas listas. Também vou explicar a principal limitação: se o sequenciador parar, os novos eventos deixam de ser ordenados.
