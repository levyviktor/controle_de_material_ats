import 'package:flutter/material.dart';
import '../services/auto_update_service.dart';

class UpdateStatusWidget extends StatelessWidget {
  final AutoUpdateService updateService;

  const UpdateStatusWidget({
    super.key,
    required this.updateService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: updateService,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: updateService.lastError != null ? Colors.red.shade50 : Colors.blue.shade50,
          child: Row(
            children: [
              // Indicador de status
              if (updateService.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else if (updateService.lastError != null)
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.red.shade600,
                )
              else
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.green.shade600,
                ),
              
              const SizedBox(width: 8),
              
              // Texto de status
              Expanded(
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: updateService.lastError != null 
                        ? Colors.red.shade700 
                        : Colors.grey.shade700,
                  ),
                ),
              ),
              
              // Contador de itens
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: updateService.lastError != null 
                      ? Colors.red.shade100 
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${updateService.items.length} itens',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: updateService.lastError != null 
                        ? Colors.red.shade700 
                        : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStatusText() {
    if (updateService.isLoading) {
      return 'Carregando dados da planilha...';
    } else if (updateService.lastError != null) {
      return 'Erro: ${updateService.lastError}';
    } else if (updateService.lastUpdate != null) {
      final now = DateTime.now();
      final diff = now.difference(updateService.lastUpdate!);
      
      if (diff.inMinutes < 1) {
        return 'Dados reais carregados agora';
      } else if (diff.inMinutes < 60) {
        return 'Dados reais atualizados há ${diff.inMinutes}min';
      } else {
        return 'Dados reais atualizados há ${diff.inHours}h';
      }
    } else {
      return 'Conectando à planilha...';
    }
  }
}
