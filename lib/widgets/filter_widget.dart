import 'package:flutter/material.dart';
import '../models/material_item.dart';

class FilterWidget extends StatefulWidget {
  final Function(Map<String, String>) onFiltersChanged;
  final List<MaterialItem> allItems;

  const FilterWidget({
    super.key,
    required this.onFiltersChanged,
    required this.allItems,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  final Map<String, String> _filters = {
    'ano': '',
    'sede': '',
    'material': '',
    'situacao': '',
    'status': '',
    'defeito': '',
    'local': '',
  };

  bool _isExpanded = false;

  void _updateFilter(String key, String value) {
    setState(() {
      _filters[key] = value;
    });
    widget.onFiltersChanged(_filters);
  }

  void _clearFilters() {
    setState(() {
      _filters.updateAll((key, value) => '');
    });
    widget.onFiltersChanged(_filters);
  }

  int get _activeFiltersCount {
    return _filters.values.where((value) => value.isNotEmpty).length;
  }

  // Extrai valores únicos dos dados reais
  List<String> _getUniqueValues(String field) {
    Set<String> uniqueValues = {};
    
    for (var item in widget.allItems) {
      String value = '';
      switch (field) {
        case 'ano':
          value = item.ano;
          break;
        case 'sede':
          value = item.sede;
          break;
        case 'material':
          value = item.material;
          break;
        case 'situacao':
          value = item.situacao;
          break;
        case 'status':
          value = item.status;
          break;
        case 'defeito':
          value = item.defeito;
          break;
        case 'local':
          value = item.local;
          break;
      }
      
      if (value.isNotEmpty && value.trim().isNotEmpty) {
        uniqueValues.add(value.trim());
      }
    }
    
    List<String> sortedValues = uniqueValues.toList();
    sortedValues.sort();
    return sortedValues;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_activeFiltersCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_activeFiltersCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              _activeFiltersCount > 0 
                  ? 'Filtros ($_activeFiltersCount ativos)'
                  : 'Filtros',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_activeFiltersCount > 0)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  // Primeira linha: Ano e Sede
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownFilter(
                          'Ano',
                          'ano',
                          _getUniqueValues('ano'),
                          Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownFilter(
                          'Sede',
                          'sede',
                          _getUniqueValues('sede'),
                          Icons.business,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Segunda linha: Material e Situação
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownFilter(
                          'Material',
                          'material',
                          _getUniqueValues('material'),
                          Icons.devices,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownFilter(
                          'Situação',
                          'situacao',
                          _getUniqueValues('situacao'),
                          Icons.info,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Terceira linha: Status
                  _buildDropdownFilter(
                    'Status',
                    'status',
                    _getUniqueValues('status'),
                    Icons.assignment_turned_in,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quarta linha: Defeito e Local
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownFilter(
                          'Defeito',
                          'defeito',
                          _getUniqueValues('defeito'),
                          Icons.error_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownFilter(
                          'Local',
                          'local',
                          _getUniqueValues('local'),
                          Icons.location_on,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String key,
    List<String> options,
    IconData icon,
  ) {
    // Se não há opções, não mostra o filtro
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: '$label (${options.length})',
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: _filters[key]!.isEmpty ? null : _filters[key],
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(
          option,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      )).toList(),
      onChanged: (value) => _updateFilter(key, value ?? ''),
      isExpanded: true,
      menuMaxHeight: 300, // Limita altura do menu dropdown
    );
  }
}
