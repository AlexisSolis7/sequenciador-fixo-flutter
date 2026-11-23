# Sequenciador fixo

Neste trabalho de Sistemas Distribuídos, vou implementar um sequenciador fixo usando Dart e Flutter para Windows. Minha ideia é fazer um chat simples em que os participantes enviam mensagens e todos mostram o histórico na mesma ordem.

Por enquanto, deixei apenas a estrutura das pastas e os arquivos vazios. O projeto ainda não executa; vou preencher o código e as configurações nas próximas etapas.

## Como vai funcionar

Vou usar um servidor como sequenciador e três clientes, identificados como P1, P2 e P3. O servidor será um programa Dart separado, e cada cliente terá uma janela Flutter.

Quando um cliente enviar uma mensagem, o servidor vai atribuir um número de sequência e distribuir a mensagem para todos, inclusive para quem enviou. Cada cliente vai guardar as mensagens recebidas e entregar ao histórico seguindo essa numeração, sem pular posições.

```text
P1, P2 e P3 → sequenciador → mensagens numeradas para P1, P2 e P3
```

## Comunicação e interface

Vou fazer a comunicação por TCP, com mensagens JSON separadas por quebra de linha. Os pedidos vão informar a identificação da mensagem e o texto; a distribuição vai incluir também a origem e o número global de sequência.

Na interface, quero mostrar o identificador do processo, o estado da conexão, o campo de envio, o histórico entregue, o buffer e o próximo número esperado.

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
  lib/models/mensagem.dart
  lib/services/conexao.dart
  lib/controllers/cliente_controller.dart
  lib/screens/cliente_screen.dart
  test/ordenacao_test.dart
  pubspec.yaml
docs/imagens/
```

## Desenvolvimento e execução

Vou precisar do Flutter com suporte a Windows e do Dart. Ainda vou configurar os arquivos `pubspec.yaml`, as dependências e os arquivos de suporte do aplicativo Windows. Depois vou registrar aqui as versões usadas e os comandos exatos para instalar e executar.

Vou desenvolver primeiro o servidor e a troca de mensagens, depois a ordenação nos clientes e a interface. Para testar, vou enviar mensagens pelos três participantes e conferir se os históricos ficam iguais.

## Relatório e apresentação

Vou completar este README com os procedimentos de instalação, configuração e execução, os resultados dos testes e imagens da interface. Também vou incluir trechos do código mostrando a identificação dos processos, o envio, a recepção e a ordenação das mensagens.

Na apresentação, quero mostrar os quatro processos funcionando e explicar a principal limitação: se o sequenciador parar, as novas mensagens deixam de ser ordenadas.
