import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/material_item.dart';
import 'package:flutter/foundation.dart';

class DataService {
  static const String csvUrl = 
      'https://docs.google.com/spreadsheets/d/1pw6IgzIEs5paZE7Ajw2Y9rIZhLt0lWLaPHYlqMhhEe4/export?format=csv&gid=1767172355';

  Future<List<MaterialItem>> loadMaterialData() async {
  try {
    final headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      'Accept': 'text/csv,application/csv,text/plain,*/*',
      'Accept-Charset': 'utf-8',
    };
    
    final response = await http.get(
      Uri.parse(csvUrl),
      headers: headers,
    ).timeout(const Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Planilha vazia ou inacessível');
      }
      
      // Corrige a codificação dos caracteres
      String csvContent = _fixEncoding(response.body);
      
      final csv = const CsvToListConverter().convert(csvContent);
      
      if (csv.isEmpty) {
        throw Exception('Dados CSV inválidos');
      }

      if (kDebugMode) {
        print('Total de linhas no CSV: ${csv.length}');
      }
      
      int startIndex = 4;
      
      if (kDebugMode) {
        print('Iniciando leitura dos dados na linha $startIndex');
      }
      
      final dataRows = csv.skip(startIndex).where((row) {
        if (row.length < 11) return false;
        
        final ano = row.length > 1 ? row[1]?.toString().trim() ?? '' : '';
        final patrimonio = row.length > 10 ? row[10]?.toString().trim() ?? '' : '';
        
        if (ano.isEmpty || 
            ano.toUpperCase().contains('TOTAIS') ||
            ano.toUpperCase().contains('TOTAL')) {
          return false;
        }
        
        return RegExp(r'^\d{4}$').hasMatch(ano) || patrimonio.isNotEmpty;
      }).toList();
      
      if (kDebugMode) {
        print('Linhas de dados válidas: ${dataRows.length}');
        if (dataRows.isNotEmpty) {
          print('Primeira linha de dados: ${dataRows.first}');
        }
      }
      
      if (dataRows.isEmpty) {
        throw Exception('Nenhuma linha de dados válida encontrada');
      }
      
      final items = dataRows.map((row) => MaterialItem.fromCsvRow(row)).toList();
      
      if (kDebugMode) {
        print('Total de itens processados: ${items.length}');
        if (items.isNotEmpty) {
          print('Primeiro item: Ano=${items.first.ano}, Patrimônio=${items.first.patrimonio}, Material=${items.first.material}');
        }
      }
      
      return items;
      
    } else {
      throw Exception('Erro HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao carregar dados: $e');
    }
    throw Exception('Erro de conexão: $e');
  }
}

// Método para corrigir a codificação dos caracteres
String _fixEncoding(String text) {
  // Mapa de correções para caracteres mal codificados
  final Map<String, String> corrections = {
    'Ã§': 'ç',
    'Ã¡': 'á',
    'Ã ': 'à',
    'Ã©': 'é',
    'Ãª': 'ê',
    'Ã­': 'í',
    'Ã³': 'ó',
    'Ãµ': 'õ',
    'Ã´': 'ô',
    'Ãº': 'ú',
    'Ã¢': 'â',
    'Ã£': 'ã',
    'Ã¼': 'ü',
    'Ã§Ã£o': 'ção',
    'Ã§Ã¡': 'çá',
    'Ã§os': 'ços',
    'NÃ£o': 'Não',
    'informÃ¡tica': 'informática',
    'serviÃ§os': 'serviços',
    'configuraÃ§Ã£o': 'configuração',
    'eletrÃ´nica': 'eletrônica',
    'mÃ¡quina': 'máquina',
    'tÃ©cnico': 'técnico',
    'manutençÃ£o': 'manutenção',
    'operaÃ§Ã£o': 'operação',
    'administraÃ§Ã£o': 'administração',
    'educaÃ§Ã£o': 'educação',
    'seguranÃ§a': 'segurança',
    'qualificaÃ§Ã£o': 'qualificação',
    'comunicaÃ§Ã£o': 'comunicação',
    'organizaÃ§Ã£o': 'organização',
    'coordenaÃ§Ã£o': 'coordenação',
    'direÃ§Ã£o': 'direção',
    'produÃ§Ã£o': 'produção',
    'construÃ§Ã£o': 'construção',
    'instalaÃ§Ã£o': 'instalação',
    'verificaÃ§Ã£o': 'verificação',
    'reparaÃ§Ã£o': 'reparação',
    'substituiÃ§Ã£o': 'substituição',
    'atualizaÃ§Ã£o': 'atualização',
    'configuraÃ§Ã£o': 'configuração',
    'programaÃ§Ã£o': 'programação',
    'calibraÃ§Ã£o': 'calibração',
    'validaÃ§Ã£o': 'validação',
    'documentaÃ§Ã£o': 'documentação',
    'especificaÃ§Ã£o': 'especificação',
    'identificaÃ§Ã£o': 'identificação',
    'localizaÃ§Ã£o': 'localização',
    'utilizaÃ§Ã£o': 'utilização',
    'otimizaÃ§Ã£o': 'otimização',
    'modernizaÃ§Ã£o': 'modernização',
    'padronizaÃ§Ã£o': 'padronização',
    'centralizaÃ§Ã£o': 'centralização',
    'descentralizaÃ§Ã£o': 'descentralização',
    'regionalizaÃ§Ã£o': 'regionalização',
    'especializaÃ§Ã£o': 'especialização',
    'generalizaÃ§Ã£o': 'generalização',
    'personalizaÃ§Ã£o': 'personalização',
    'automatizaÃ§Ã£o': 'automatização',
    'digitalizaÃ§Ã£o': 'digitalização',
    'virtualizaÃ§Ã£o': 'virtualização',
    'sincronizaÃ§Ã£o': 'sincronização',
    'integraÃ§Ã£o': 'integração',
    'migraÃ§Ã£o': 'migração',
    'implementaÃ§Ã£o': 'implementação',
    'demonstraÃ§Ã£o': 'demonstração',
    'apresentaÃ§Ã£o': 'apresentação',
    'representaÃ§Ã£o': 'representação',
    'interpretaÃ§Ã£o': 'interpretação',
    'traduÃ§Ã£o': 'tradução',
    'adaptaÃ§Ã£o': 'adaptação',
    'modificaÃ§Ã£o': 'modificação',
    'alteraÃ§Ã£o': 'alteração',
    'correÃ§Ã£o': 'correção',
    'proteÃ§Ã£o': 'proteção',
    'prevenÃ§Ã£o': 'prevenção',
    'detecÃ§Ã£o': 'detecção',
    'seleÃ§Ã£o': 'seleção',
    'coleÃ§Ã£o': 'coleção',
    'conexÃ£o': 'conexão',
    'extensÃ£o': 'extensão',
    'dimensÃ£o': 'dimensão',
    'compreensÃ£o': 'compreensÃ£o',
    'expansÃ£o': 'expansão',
    'suspensÃ£o': 'suspensÃ£o',
    'tensÃ£o': 'tensão',
    'atenÃ§Ã£o': 'atenção',
    'intenÃ§Ã£o': 'intenção',
    'retenÃ§Ã£o': 'retenção',
    'contenÃ§Ã£o': 'contenção',
    'obtenÃ§Ã£o': 'obtenção',
    'manutençÃ£o': 'manutenção',
    'sustentaÃ§Ã£o': 'sustentação',
    'orientaÃ§Ã£o': 'orientação',
    'concentraÃ§Ã£o': 'concentração',
    'fundamentaÃ§Ã£o': 'fundamentação',
    'instrumentaÃ§Ã£o': 'instrumentação',
    'segmentaÃ§Ã£o': 'segmentação',
    'fragmentaÃ§Ã£o': 'fragmentação',
    'argumentaÃ§Ã£o': 'argumentação',
    'documentaÃ§Ã£o': 'documentação',
    'experimentaÃ§Ã£o': 'experimentação',
    'implementaÃ§Ã£o': 'implementação',
    'complementaÃ§Ã£o': 'complementação',
    'suplementaÃ§Ã£o': 'suplementação',
    'regulamentaÃ§Ã£o': 'regulamentação',
  };
  
  String correctedText = text;
  
  // Aplica todas as correções
  corrections.forEach((wrong, correct) {
    correctedText = correctedText.replaceAll(wrong, correct);
  });
  
  return correctedText;
}
}
