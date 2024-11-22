import 'package:acesso_mapeado/shared/logger.dart';
import 'package:flutter/material.dart';
import 'package:acesso_mapeado/shared/design_system.dart';

class AccessibilitySection extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> items;

  const AccessibilitySection({
    super.key,
    required this.category,
    required this.items,
  });

  IconData _getIconForTipo(String tipo) {
    Logger.logInfo('Tipo: $tipo');
    switch (tipo) {
      case 'Acessibilidade Sensorial':
        return Icons.hearing;
      case 'Acessibilidade Física':
        return Icons.accessible;
      case 'Acessibilidade Atitudinal':
        return Icons.handshake_rounded;
      case 'Acessibilidade Comunicacional':
        return Icons.chat;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(_getIconForTipo(category), color: AppColors.lightPurple),
          const SizedBox(width: AppSpacing.small),
          Text(
            category,
            style: const TextStyle(
              fontSize: AppTypography.large,
              color: AppColors.black,
            ),
          ),
        ],
      ),
      children: items.map((item) {
        return ListTile(
          title: Text(
            item["tipo"] ?? 'Tipo não disponível',
            style: const TextStyle(color: AppColors.darkGray),
          ),
          trailing: item["status"] ?? false
              ? const Icon(Icons.check, color: Colors.green)
              : const Icon(Icons.close, color: Colors.red),
        );
      }).toList(),
    );
  }
}
