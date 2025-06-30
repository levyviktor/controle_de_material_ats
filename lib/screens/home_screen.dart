import 'package:flutter/material.dart';
import '../services/auto_update_service.dart';
import '../models/material_item.dart';
import '../widgets/filter_widget.dart';
import '../widgets/material_card.dart';
import '../widgets/update_status_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AutoUpdateService _updateService = AutoUpdateService();
  List<MaterialItem> _filteredItems = [];
  String _searchQuery = '';
  Map<String, String> _filters = {};

  @override
  void initState() {
    super.initState();
    _updateService.addListener(_onDataUpdated);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Inicializa notificações
    await _updateService.initializeNotifications();
    
    // Se não tem permissão, mostra dialog para solicitar
    if (!_updateService.notificationsEnabled) {
      _showNotificationPermissionDialog();
    }
    
    // Inicia o serviço de atualização
    _updateService.startAutoUpdate();
  }

  void _showNotificationPermissionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Ativar Notificações'),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deseja receber notificações quando:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.update, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(child: Text('A planilha for atualizada')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.add_circle, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text('Novos dados forem adicionados')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.error, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(child: Text('Ocorrerem erros de conexão')),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Agora Não'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final granted = await _updateService.requestNotificationPermission();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          granted 
                              ? 'Notificações ativadas com sucesso! 🔔'
                              : 'Notificações não foram ativadas',
                        ),
                        backgroundColor: granted ? Colors.green : Colors.orange,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ativar'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _updateService.removeListener(_onDataUpdated);
    _updateService.dispose();
    super.dispose();
  }

  void _onDataUpdated() {
    if (mounted) {
      setState(() {
        _applyFilters();
      });
      
      // Mostra notificação quando dados são atualizados (apenas no app)
      if (_updateService.lastUpdate != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dados atualizados às ${_formatTime(_updateService.lastUpdate!)}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Mostra erro se houver
      if (_updateService.lastError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${_updateService.lastError}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _applyFilters() {
    _filteredItems = _updateService.items.where((item) {
      // Filtro de busca geral
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!item.patrimonio.toLowerCase().contains(searchLower) &&
            !item.configuracao.toLowerCase().contains(searchLower) &&
            !item.material.toLowerCase().contains(searchLower) &&
            !item.defeito.toLowerCase().contains(searchLower) &&
            !item.local.toLowerCase().contains(searchLower) &&
            !item.sede.toLowerCase().contains(searchLower) &&
            !item.setor.toLowerCase().contains(searchLower) &&
            !item.serialNumber.toLowerCase().contains(searchLower) &&
            !item.os.toLowerCase().contains(searchLower) &&
            !item.situacao.toLowerCase().contains(searchLower) &&
            !item.status.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Filtros específicos
      for (final entry in _filters.entries) {
        if (entry.value.isNotEmpty) {
          switch (entry.key) {
            case 'ano':
              if (!item.ano.contains(entry.value)) return false;
              break;
            case 'sede':
              if (!item.sede.toLowerCase().contains(entry.value.toLowerCase())) return false;
              break;
            case 'situacao':
              if (!item.situacao.toLowerCase().contains(entry.value.toLowerCase())) return false;
              break;
            case 'status':
              if (!item.status.toLowerCase().contains(entry.value.toLowerCase())) return false;
              break;
            case 'material':
              if (!item.material.toLowerCase().contains(entry.value.toLowerCase())) return false;
              break;
            case 'defeito':
              if (!item.defeito.toLowerCase().contains(entry.value.toLowerCase())) return false;
              break;
            case 'local':
              if (!item.local.toLowerCase().contains(entry.value.toLowerCase())) return false;
              break;
          }
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Controle de Materiais',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão de notificações
          IconButton(
            icon: Icon(
              _updateService.notificationsEnabled 
                  ? Icons.notifications_active 
                  : Icons.notifications_off,
            ),
            onPressed: () async {
              if (!_updateService.notificationsEnabled) {
                final granted = await _updateService.requestNotificationPermission();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        granted 
                            ? 'Notificações ativadas! 🔔'
                            : 'Permissão negada',
                      ),
                      backgroundColor: granted ? Colors.green : Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notificações já estão ativas! 🔔'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _updateService.forceUpdate();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status de atualização
          UpdateStatusWidget(updateService: _updateService),
          
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar por patrimônio, defeito, local...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          
          // Filtros
          FilterWidget(
            allItems: _updateService.items,
            onFiltersChanged: (filters) {
              setState(() {
                _filters = filters;
                _applyFilters();
              });
            },
          ),

          // Lista de itens
          Expanded(
            child: _updateService.isLoading && _updateService.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Carregando dados...'),
                      ],
                    ),
                  )
                : _filteredItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum item encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return MaterialCard(item: _filteredItems[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
