class MessageThread {
  final String id;
  final String from;
  final String lastMessage;
  final DateTime updatedAt;

  MessageThread({
    required this.id,
    required this.from,
    required this.lastMessage,
    required this.updatedAt,
  });
}

class MessageService {
  MessageService._internal();
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;

  final List<MessageThread> _threads = [
    MessageThread(
      id: '1',
      from: 'Mr. Kamau (Landlord)',
      lastMessage: 'Hello, viewing is available tomorrow at 3pm.',
      updatedAt: DateTime.now(),
    ),
  ];

  List<MessageThread> getAll() => List.unmodifiable(_threads);

  void addDemoMessage() {
    _threads.insert(
      0,
      MessageThread(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: 'New Landlord',
        lastMessage: 'Please share your preferred time to view the room.',
        updatedAt: DateTime.now(),
      ),
    );
  }

  void clear() => _threads.clear();
}