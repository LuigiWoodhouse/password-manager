import 'package:flutter/material.dart';

class PasswordList extends StatelessWidget {
  final Map<String, Map<String, String>> passwords;
  final Map<String, bool> visibility;
  final ValueChanged<String> onToggleVisibility;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onUpdate;

  const PasswordList({
    super.key,
    required this.passwords,
    required this.visibility,
    required this.onToggleVisibility,
    required this.onRemove,
    required this.onCopy,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: passwords.length,
      itemBuilder: (context, index) {
        String name = passwords.keys.elementAt(index);
        String password = passwords[name]!['value']!;
        String timestamp = passwords[name]!['timestamp']!;
        bool isVisible = visibility[name] ?? false;

        return ListTile(
          title: Text(name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(isVisible ? password : '••••••••',style: TextStyle(fontSize: 8.0)),
              SizedBox(height: 4.0), // Adjust space between password and timestamp
                 Text(
                '($timestamp)',
                style: TextStyle(fontSize: 6.0, color: Colors.grey), // Adjust timestamp style
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,size: 13.0),
                onPressed: () => onToggleVisibility(name),
              ),
              IconButton(
                icon: const Icon(Icons.copy,size: 13.0),
                onPressed: () => onCopy(password),
              ),
              IconButton(
                icon: const Icon(Icons.delete,size: 13.0),
                onPressed: () => onRemove(name),
              ),
            ],
          ),
          onLongPress: () => onUpdate(name),
        );
      },
    );
  }
}
