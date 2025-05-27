class MaterialItem {
  final String ano;
  final String envio;
  final String diasAssistencia;
  final String local;
  final String material;
  final String configuracao;
  final String defeito;
  final String sede;
  final String setor;
  final String patrimonio;
  final String serialNumber;
  final String os;
  final String situacao;
  final String status;
  final String dataRetorno;
  final String diasConserto;
  final String observacoes;

  MaterialItem({
    required this.ano,
    required this.envio,
    required this.diasAssistencia,
    required this.local,
    required this.material,
    required this.configuracao,
    required this.defeito,
    required this.sede,
    required this.setor,
    required this.patrimonio,
    required this.serialNumber,
    required this.os,
    required this.situacao,
    required this.status,
    required this.dataRetorno,
    required this.diasConserto,
    required this.observacoes,
  });

  factory MaterialItem.fromCsvRow(List<dynamic> row) {
    // O CSV tem uma coluna vazia no início, então os dados começam na coluna 1
    // [, ANO, ENVIO, DIAS NA ASSIST., LOCAL, MATERIAL, CONFIGURAÇÃO, DEFEITO, SEDE, SETOR, PATRIM, S/N, OS, SITUAÇÃO, STATUS, DATA RETORNO, DIAS PARA CONSERTO, OBS]
    //  0   1     2         3            4       5          6           7        8      9       10    11   12      13        14         15              16               17
    
    return MaterialItem(
      ano: row.length > 1 ? row[1]?.toString().trim() ?? '' : '',
      envio: row.length > 2 ? row[2]?.toString().trim() ?? '' : '',
      diasAssistencia: row.length > 3 ? row[3]?.toString().trim() ?? '' : '',
      local: row.length > 4 ? row[4]?.toString().trim() ?? '' : '',
      material: row.length > 5 ? row[5]?.toString().trim() ?? '' : '',
      configuracao: row.length > 6 ? row[6]?.toString().trim() ?? '' : '',
      defeito: row.length > 7 ? row[7]?.toString().trim() ?? '' : '',
      sede: row.length > 8 ? row[8]?.toString().trim() ?? '' : '',
      setor: row.length > 9 ? row[9]?.toString().trim() ?? '' : '',
      patrimonio: row.length > 10 ? row[10]?.toString().trim() ?? '' : '',
      serialNumber: row.length > 11 ? row[11]?.toString().trim() ?? '' : '',
      os: row.length > 12 ? row[12]?.toString().trim() ?? '' : '',
      situacao: row.length > 13 ? row[13]?.toString().trim() ?? '' : '',
      status: row.length > 14 ? row[14]?.toString().trim() ?? '' : '',
      dataRetorno: row.length > 15 ? row[15]?.toString().trim() ?? '' : '',
      diasConserto: row.length > 16 ? row[16]?.toString().trim() ?? '' : '',
      observacoes: row.length > 17 ? row[17]?.toString().trim() ?? '' : '',
    );
  }
}
