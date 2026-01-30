class ColombianMilitaryRanks {
  static const Map<String, List<String>> policeRanks = {
    'oficiales': [
      'GENERAL',
      'MAYOR GENERAL',
      'BRIGADIER GENERAL',
      'CORONEL',
      'TENIENTE CORONEL',
      'MAYOR',
      'CAPITÁN',
      'TENIENTE',
      'SUBTENIENTE',
    ],
    'suboficiales': [
      'SARGENTO MAYOR',
      'SARGENTO PRIMERO',
      'SARGENTO VICEPRIMERO',
      'SARGENTO SEGUNDO',
      'CABO PRIMERO',
      'CABO SEGUNDO',
    ],
    'nivel_ejecutivo': [
      "SUBINTENDENTE",
      "INTENDENTE",
      "INTENDENTE JEFE",
      "SUBCOMISARIO",
      "COMISARIO",
      'PATRULLERO',
      'AGENTE',
      'AUXILIAR DE POLICIA',
    ],
  };

  static const Map<String, List<String>> armyRanks = {
    'oficiales': [
      'GENERAL',
      'MAYOR GENERAL',
      'BRIGADIER GENERAL',
      'CORONEL',
      'TENIENTE CORONEL',
      'MAYOR',
      'CAPITÁN',
      'TENIENTE',
      'SUBTENIENTE',
    ],
    'suboficiales': [
      'SARGENTO MAYOR',
      'SARGENTO PRIMERO',
      'SARGENTO SEGUNDO',
      'CABO PRIMERO',
      'CABO SEGUNDO',
    ],
    'soldados': ['SOLDADO PROFESIONAL', 'SOLDADO'],
  };

  static const Map<String, List<String>> navyRanks = {
    'oficiales': [
      'ALMIRANTE',
      'VICEALMIRANTE',
      'CONTRALMIRANTE',
      'CAPITÁN DE NAVÍO',
      'CAPITÁN DE FRAGATA',
      'CAPITÁN DE CORBETA',
      'TENIENTE DE NAVÍO',
      'TENIENTE DE FRAGATA',
      'ALFÉREZ DE NAVÍO',
    ],
    'suboficiales': [
      'SUBOFICIAL MAYOR',
      'SUBOFICIAL PRIMERO',
      'SUBOFICIAL SEGUNDO',
      'MARINERO PRIMERO',
      'MARINERO SEGUNDO',
    ],
  };

  static const Map<String, List<String>> airForceRanks = {
    'oficiales': [
      'GENERAL',
      'MAYOR GENERAL',
      'BRIGADIER GENERAL',
      'CORONEL',
      'TENIENTE CORONEL',
      'MAYOR',
      'CAPITÁN',
      'TENIENTE',
      'SUBTENIENTE',
    ],
    'suboficiales': [
      'TÉCNICO MAYOR',
      'TÉCNICO PRIMERO',
      'TÉCNICO SEGUNDO',
      'SOLDADO PRIMERO',
      'SOLDADO SEGUNDO',
    ],
  };

  static List<String> getAllValidRanks() {
    final allRanks = <String>[];
    for (final institution in [
      policeRanks,
      armyRanks,
      navyRanks,
      airForceRanks,
    ]) {
      for (final ranks in institution.values) {
        allRanks.addAll(ranks);
      }
    }
    return allRanks.toSet().toList();
  }

  static bool isValidRankForInstitution(String rank, String institution) {
    final cleanRank = rank.toUpperCase().trim();
    final cleanInstitution = institution.toUpperCase();

    if (cleanInstitution.contains('POLICIA')) {
      return policeRanks.values.any((ranks) => ranks.contains(cleanRank));
    } else if (cleanInstitution.contains('EJERCITO') ||
        cleanInstitution.contains('EJÉRCITO')) {
      return armyRanks.values.any((ranks) => ranks.contains(cleanRank));
    } else if (cleanInstitution.contains('ARMADA')) {
      return navyRanks.values.any((ranks) => ranks.contains(cleanRank));
    } else if (cleanInstitution.contains('FUERZA AEREA') ||
        cleanInstitution.contains('FUERZA AÉREA')) {
      return airForceRanks.values.any((ranks) => ranks.contains(cleanRank));
    }
    return false;
  }

  static String? extractInstitution(String documentText) {
    final text = documentText.toUpperCase();
    if (text.contains('POLICIA NACIONAL')) return 'POLICIA NACIONAL';
    if (text.contains('EJERCITO NACIONAL')) return 'EJERCITO NACIONAL';
    if (text.contains('ARMADA NACIONAL')) return 'ARMADA NACIONAL';
    if (text.contains('FUERZA AEREA') || text.contains('FUERZA AÉREA')) {
      return 'FUERZA AEREA';
    }
    return null;
  }
}
