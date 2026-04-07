import 'package:flutter/material.dart';
import '../../services/message_service.dart';

class InboxScreen extends StatefulWidget {
  static const routeName = '/inbox';
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final MessageService _messageService = MessageService();
  late List<MessageThread> _threads;

  @override
  void initState() {
    super.initState();
    _threads = _messageService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox / Messages'),
        backgroundColor: const Color(0xFFF68B1E),
      ),
      body: _threads.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No messages yet. When a landlord sends you an inquiry, it will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              itemCount: _threads.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = _threads[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(thread.from),
                  subtitle: Text(thread.lastMessage),
                  trailing: Text(
                    _formatTime(thread.updatedAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Open thread feature not yet implemented.')),
                    );
                  },
                );
              },
            ),
      floatingActionButton: _threads.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _messageService.addDemoMessage();
                  _threads = _messageService.getAll();
                });
              },
              backgroundColor: const Color(0xFFF68B1E),
              child: const Icon(Icons.refresh),
              tooltip: 'Fetch latest messages',
            ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.month}/${time.day}/${time.year}';
  }
}
