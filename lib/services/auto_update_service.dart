import 'dart:async';
import 'package:flutter/foundation.dart';
import 'data_service.dart';
import '../models/material_item.dart';

class AutoUpdateService extends ChangeNotifier {
  final DataService _dataService = DataService();
  Timer? _timer;
  List<MaterialItem> _items = [];
  bool _isLoading = false;
  String? _lastError;
  DateTime? _lastUpdate;

  List<MaterialItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  DateTime? get lastUpdate => _lastUpdate;

  // Configurações de atualização
  static const Duration _updateInterval = Duration(minutes: 5);
  static const Duration _retryInterval = Duration(minutes: 1);

  void startAutoUpdate() {
    // Carrega dados inicialmente
    loadData();
    
    // Configura timer para atualizações periódicas
    _timer = Timer.periodic(_updateInterval, (timer) {
      loadData();
    });
  }

  void stopAutoUpdate() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> loadData() async {
    if (_isLoading) return; // Evita múltiplas requisições simultâneas

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newItems = await _dataService.loadMaterialData();
      
      if (kDebugMode) {
        print('AutoUpdateService: ${newItems.length} itens carregados');
      }
      
      // Verifica se houve mudanças nos dados
      if (!_areListsEqual(_items, newItems)) {
        _items = newItems;
        _lastUpdate = DateTime.now();
        
        if (kDebugMode) {
          print('Dados atualizados: ${_items.length} itens carregados');
        }
      }
      
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      
      if (kDebugMode) {
        print('Erro ao carregar dados: $e');
      }
      
      // Em caso de erro, tenta novamente em 1 minuto
      _scheduleRetry();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _scheduleRetry() {
    Timer(_retryInterval, () {
      if (_lastError != null) {
        loadData();
      }
    });
  }

  bool _areListsEqual(List<MaterialItem> list1, List<MaterialItem> list2) {
    if (list1.length != list2.length) return false;
    
    for (int i = 0; i < list1.length; i++) {
      if (!_areItemsEqual(list1[i], list2[i])) {
        return false;
      }
    }
    
    return true;
  }

  bool _areItemsEqual(MaterialItem item1, MaterialItem item2) {
    return item1.patrimonio == item2.patrimonio &&
           item1.status == item2.status &&
           item1.situacao == item2.situacao &&
           item1.dataRetorno == item2.dataRetorno &&
           item1.diasConserto == item2.diasConserto;
  }

  // Força uma atualização manual
  Future<void> forceUpdate() async {
    await loadData();
  }

  @override
  void dispose() {
    stopAutoUpdate();
    super.dispose();
  }
}
