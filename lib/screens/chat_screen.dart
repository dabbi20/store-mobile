import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../models/user.dart';
import '../services/socket_service.dart';

class ChatScreen extends StatefulWidget {
  final User currentUser;

  const ChatScreen({super.key, required this.currentUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ========================================
  // SERVICIOS
  // ========================================

  final SocketService socketService = SocketService();

  // ========================================
  // CONTROLADORES
  // ========================================

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  // ========================================
  // ESTADOS
  // ========================================

  List<ChatMessage> messages = [];

  bool isConnected = false;

  String? error;

  // ========================================
  // INICIALIZACIÓN
  // ========================================

  @override
  void initState() {
    super.initState();

    connectToChat();
  }

  // ========================================
  // CONECTAR AL CHAT
  // ========================================

  Future<void> connectToChat() async {
    await socketService.connect(
      // ========================================
      // HISTORIAL
      // ========================================

      onHistory: (history) {
        if (!mounted) {
          return;
        }

        setState(() {
          messages = history;
          error = null;
        });

        scrollToBottom();
      },

      // ========================================
      // NUEVO MENSAJE
      // ========================================
      onNewMessage: (message) {
        if (!mounted) {
          return;
        }

        setState(() {
          messages.add(message);
        });

        scrollToBottom();
      },

      // ========================================
      // ERROR
      // ========================================
      onError: (message) {
        if (!mounted) {
          return;
        }

        setState(() {
          error = message;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },

      // ========================================
      // CONECTADO
      // ========================================
      onConnected: () {
        if (!mounted) {
          return;
        }

        setState(() {
          isConnected = true;
          error = null;
        });
      },

      // ========================================
      // DESCONECTADO
      // ========================================
      onDisconnected: () {
        if (!mounted) {
          return;
        }

        setState(() {
          isConnected = false;
        });
      },
    );
  }

  // ========================================
  // ENVIAR MENSAJE
  // ========================================

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    try {
      socketService.sendMessage(text);

      messageController.clear();
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // ========================================
  // BAJAR AL ÚLTIMO MENSAJE
  // ========================================

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ========================================
  // LIBERAR RECURSOS
  // ========================================

  @override
  void dispose() {
    socketService.disconnect();

    messageController.dispose();

    scrollController.dispose();

    super.dispose();
  }

  // ========================================
  // INTERFAZ
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          // ========================================
          // ESTADO DE CONEXIÓN
          // ========================================

          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    isConnected ? Icons.circle : Icons.circle_outlined,
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Text(isConnected ? 'Conectado' : 'Desconectado'),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ========================================
          // ERROR
          // ========================================

          if (error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),

          // ========================================
          // MENSAJES
          // ========================================
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No hay mensajes todavía'))
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isMine = message.userId == widget.currentUser.id;

                      return _MessageBubble(message: message, isMine: isMine);
                    },
                  ),
          ),

          // ========================================
          // CAMPO PARA ESCRIBIR
          // ========================================
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      enabled: isConnected,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (isConnected) {
                          sendMessage();
                        }
                      },
                      decoration: InputDecoration(
                        hintText: isConnected
                            ? 'Escribe un mensaje...'
                            : 'Conectando al chat...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: isConnected ? sendMessage : null,
                    tooltip: 'Enviar',
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// BURBUJA DE MENSAJE
// ========================================

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMine ? '${message.username} (Tú)' : message.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
