import 'package:flutter/material.dart';

class CustomListPrivacyBadge extends StatelessWidget {
  final bool isPublic;
  final bool small;

  const CustomListPrivacyBadge({
    super.key,
    required this.isPublic,
    this.small = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: isPublic 
            ? Colors.green.withValues(alpha: 0.15) 
            : Colors.blueGrey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPublic 
              ? Colors.green.withValues(alpha: 0.3) 
              : Colors.blueGrey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.public : Icons.lock,
            size: small ? 10 : 12,
            color: isPublic ? Colors.green : Colors.blueGrey,
          ),
          const SizedBox(width: 4),
          Text(
            isPublic ? 'Pública' : 'Privada',
            style: TextStyle(
              fontSize: small ? 9 : 11,
              fontWeight: FontWeight.bold,
              color: isPublic ? Colors.green : Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}
