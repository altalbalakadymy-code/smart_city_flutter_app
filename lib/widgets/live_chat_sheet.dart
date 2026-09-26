import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LiveChatSheet extends StatefulWidget {
  final String targetId;
  final String targetName;
  final String targetSubtitle;
  final IconData targetIcon;
  final Color themeColor;
  final Map<String, dynamic> currentUser;

  const LiveChatSheet({
    super.key,
    required this.targetId,
    required this.targetName,
    required this.targetSubtitle,
    required this.targetIcon,
    required this.themeColor,
    required this.currentUser,
  });

  static void show(
    BuildContext context, {
    required String targetId,
    required String targetName,
    required String targetSubtitle,
    required IconData targetIcon,
    required Color themeColor,
    required Map<String, dynamic> currentUser,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LiveChatSheet(
        targetId: targetId,
        targetName: targetName,
        targetSubtitle: targetSubtitle,
        targetIcon: targetIcon,
        themeColor: themeColor,
        currentUser: currentUser,
      ),
    );
  }

  @override
  State<LiveChatSheet> createState() => _LiveChatSheetState();
}

class _LiveChatSheetState extends State<LiveChatSheet> {
  final TextEditingController _msgCtrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  String get _myId => widget.currentUser['id']?.toString() ?? '1';
  String get _myRole => widget.currentUser['role']?.toString() ?? 'CLIENT';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final msgs = await ApiService.fetchChatHistory(
      targetId: widget.targetId,
      userId: _myId,
    );
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final newMsg = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender_id': _myId,
      'receiver_id': widget.targetId,
      'sender_role': _myRole,
      'message': text,
      'created_at': 'الآن',
    };

    setState(() {
      _messages.add(newMsg);
      _msgCtrl.clear();
    });

    await ApiService.sendChatMessage(
      senderId: _myId,
      receiverId: widget.targetId,
      senderRole: _myRole,
      message: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: 480,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.themeColor,
                      child: Icon(widget.targetIcon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.targetName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(widget.targetSubtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, idx) {
                        final m = _messages[idx];
                        final isMe = m['sender_id'] == _myId;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              m['message'].toString(),
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك المباشرة...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send, size: 20),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
