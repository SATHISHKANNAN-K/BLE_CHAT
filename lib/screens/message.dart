import 'package:flutter/material.dart';
import 'package:bluetooth/main.dart';
import 'package:bluetooth/chatbox.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  final messages = <Message>[];

  @override
  void initState() {
    super.initState();
    allBluetooth.listenForData.listen((event) {
      messages.add(Message(
        message: event.toString(),
        isMe: false,
      ));
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                allBluetooth.closeConnection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 42, 177, 255), // Text color
                elevation: 4, // Elevation when pressed
              ),
              child: const Text(
                "CLOSE",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChatBubble(
                      clipper: ChatBubbleClipper4(
                        type: message.isMe
                            ? BubbleType.sendBubble
                            : BubbleType.receiverBubble,
                      ),
                      alignment:
                          message.isMe ? Alignment.topRight : Alignment.topLeft,
                      child: Text(message.message),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type here ...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final message = messageController.text;
                    allBluetooth.sendMessage(message);
                    messageController.clear();
                    messages.add(
                      Message(
                        message: message,
                        isMe: true,
                      ),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.send_rounded),
                )
              ],
            )
          ],
        ));
  }
}
