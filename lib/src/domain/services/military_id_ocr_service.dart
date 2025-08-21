import 'dart:developer';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:heroes_app/src/domain/models/colombian_military_ranks.dart';
import 'package:heroes_app/src/domain/models/verification_models.dart';
import 'package:image_picker/image_picker.dart';

class MilitaryIDOCRService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<OCRResult<MilitaryIDData>> extractMilitaryIDData(
      XFile imageFile) async {
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final extractedData = _parseMilitaryIDText(recognizedText.text);

      return OCRResult(
        success: extractedData.isValidMilitaryDocument,
        data: extractedData,
        error: extractedData.isValidMilitaryDocument
            ? null
            : 'Documento militar no válido',
        confidence: extractedData.documentConfidence,
      );
    } catch (e) {
      log('Error processing image: $e');
      return OCRResult(
        success: false,
        data: null,
        error: 'Error procesando imagen: ${e.toString()}',
        confidence: 0.0,
      );
    }
  }

  MilitaryIDData _parseMilitaryIDText(String text) {
    final lines =
        text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    final fullText = text.toUpperCase();

    final hasMinistryHeader = fullText.contains('MINISTERIO DE DEFENSA NACIONAL');

    final institution = ColombianMilitaryRanks.extractInstitution(fullText);

    final militaryRank = _extractMilitaryRank(lines, fullText);

    final identificationNumber = _extractIDNumber(fullText);

    final names = _extractNames(lines);

    final confidence = _calculateDocumentConfidence(
      hasMinistryHeader: hasMinistryHeader,
      institution: institution,
      militaryRank: militaryRank,
      identificationNumber: identificationNumber,
      names: names,
    );

    return MilitaryIDData(
      identificationNumber: identificationNumber,
      firstName: names['firstName'],
      lastName: names['lastName'],
      militaryRank: militaryRank,
      institution: institution,
      hasMinistryHeader: hasMinistryHeader,
      documentConfidence: confidence,
    );
  }

  String? _extractMilitaryRank(List<String> lines, String fullText) {
    // Enhanced rank extraction with fuzzy matching
    
    // First try: Look for "Grado del titular" section with flexible patterns
    // Handle common OCR errors like "Crado cl Titular"
    final gradoPatterns = [
      RegExp(r'GRADO\s+DEL\s+TITULAR[:\s]*(.+)', caseSensitive: false),
      RegExp(r'CRADO\s+CL\s+TITULAR[:\s]*(.+)', caseSensitive: false), // Common OCR error
      RegExp(r'CRADO\s+DEL\s+TITULAR[:\s]*(.+)', caseSensitive: false), // OCR variant
      RegExp(r'GRADO\s+CL\s+TITULAR[:\s]*(.+)', caseSensitive: false),  // OCR variant
      RegExp(r'GRADO[:\s]*(.+)', caseSensitive: false),
      RegExp(r'CRADO[:\s]*(.+)', caseSensitive: false), // OCR error for GRADO
      RegExp(r'TITULAR[:\s]*(.+)', caseSensitive: false),
    ];
    
    for (final pattern in gradoPatterns) {
      final match = pattern.firstMatch(fullText);
      if (match != null) {
        final extractedText = match.group(1)?.trim().toUpperCase();
        if (extractedText != null) {
          final rank = _findBestRankMatch(extractedText);
          if (rank != null) return rank;
        }
      }
    }

    // Second try: Look through lines for rank patterns  
    // ID structure: RANK VALUE is ABOVE the "GRADO" title
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      
      // Check if line contains "GRADO" and look at PREVIOUS lines for the value
      if (line.contains('GRADO') || line.contains('CRADO')) {
        // Look at previous lines for the rank value
        for (int j = i - 1; j >= 0 && j >= i - 3; j--) {
          final candidateLine = lines[j].toUpperCase();
          final rank = _findBestRankMatch(candidateLine);
          if (rank != null) {
            log('OCR DEBUG: Found GRADO title at line $i: "$line" -> rank from line $j: "$rank"');
            return rank;
          }
        }
      }
    }

    // Third try: Fuzzy search through entire text
    return _findBestRankMatch(fullText);
  }

  String? _findBestRankMatch(String text) {
    final allRanks = ColombianMilitaryRanks.getAllValidRanks();
    
    // Handle specific OCR errors for ranks
    final rankOcrMap = {
      'AUXILIAR DE POLICIA': ['XILIAR DE POLICIA', 'AUXLIAR DE POLICIA', 'AUXILIAR POLICIA'],
      'PATRULLERO': ['PATULLERO', 'PATRULERO', 'PATRLLERO'],
      'CABO PRIMERO': ['CABO PRIMRO', 'CAO PRIMERO'],
      'SARGENTO SEGUNDO': ['SARGENTO SEGUNDO', 'SARGETO SEGUNDO'],
    };
    
    // First: Check for specific OCR error patterns
    for (final entry in rankOcrMap.entries) {
      final correctRank = entry.key;
      final ocrVariants = entry.value;
      
      for (final variant in ocrVariants) {
        if (text.contains(variant)) {
          return correctRank;
        }
      }
    }
    
    // Second: Exact match
    for (final rank in allRanks) {
      if (text.contains(rank.toUpperCase())) {
        return rank;
      }
    }
    
    // Third: Enhanced partial matching
    String? bestMatch;
    double bestSimilarity = 0.0;
    
    for (final rank in allRanks) {
      // Calculate direct similarity
      final similarity = _calculateStringSimilarity(text, rank.toUpperCase());
      if (similarity > bestSimilarity && similarity >= 0.5) { // Lowered threshold
        bestSimilarity = similarity;
        bestMatch = rank;
      }
      
      // Word-by-word matching with partial word support
      final rankWords = rank.toUpperCase().split(' ');
      double totalWordSimilarity = 0.0;
      
      for (final word in rankWords) {
        if (text.contains(word)) {
          totalWordSimilarity += 1.0;
        } else {
          final partialMatch = _findPartialWordMatch(text, word);
          if (partialMatch != null) {
            totalWordSimilarity += _calculateStringSimilarity(partialMatch, word);
          }
        }
      }
      
      final avgWordSimilarity = rankWords.isNotEmpty ? totalWordSimilarity / rankWords.length : 0.0;
      if (avgWordSimilarity >= 0.6 && avgWordSimilarity > bestSimilarity) {
        bestSimilarity = avgWordSimilarity;
        bestMatch = rank;
      }
    }
    
    return bestMatch;
  }

  String? _findPartialWordMatch(String text, String word) {
    // Find partial matches for words (handling OCR errors like XILIAR for AUXILIAR)
    if (word.length < 4) return null; // Too short for partial matching
    
    final minLength = (word.length * 0.6).round(); // At least 60% of characters must match
    final words = text.split(RegExp(r'\s+'));
    
    for (final textWord in words) {
      if (textWord.length >= minLength) {
        final similarity = _calculateStringSimilarity(textWord, word);
        if (similarity >= 0.7) { // 70% similarity for partial word match
          return textWord;
        }
      }
    }
    
    return null;
  }

  double _calculateStringSimilarity(String a, String b) {
    // Simple Jaro-Winkler-like similarity calculation
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final maxLength = a.length > b.length ? a.length : b.length;
    final minLength = a.length < b.length ? a.length : b.length;
    
    int matches = 0;
    for (int i = 0; i < minLength; i++) {
      if (i < a.length && i < b.length && a[i] == b[i]) {
        matches++;
      }
    }
    
    return matches / maxLength;
  }

  String? _extractIDNumber(String text) {
    final patterns = [
      RegExp(r'\b(\d{1,3}\.?\d{3}\.?\d{3}\.?\d{0,3})\b'),
      RegExp(r'\b(\d{8,11})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)?.replaceAll('.', '').replaceAll(' ', '');
      }
    }
    return null;
  }

  Map<String, String?> _extractNames(List<String> lines) {
    // Enhanced name extraction for Colombian military IDs
    // ID shows "NOMBRES" (compound: first + second name) and "APELLIDOS" (compound: first + second lastname)
    
    String? nombresCompound;  // From ID card "NOMBRES" field
    String? apellidosCompound; // From ID card "APELLIDOS" field
    
    // Extract compound fields from document
    // ID structure: VALUE is ABOVE the title, not below!
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toUpperCase();
      
      // Look for "NOMBRES" or variations - value is in PREVIOUS line (i-1)
      if (_containsVariation(line, 'NOMBRES') && i - 1 >= 0) {
        nombresCompound = lines[i - 1].trim();
        log('OCR DEBUG: Found NOMBRES title at line $i: "$line" -> value from line ${i-1}: "$nombresCompound"');
      } 
      // Look for "APELLIDOS" or variations - value is in PREVIOUS line (i-1)
      else if (_containsVariation(line, 'APELLIDOS') && i - 1 >= 0) {
        apellidosCompound = lines[i - 1].trim();
        log('OCR DEBUG: Found APELLIDOS title at line $i: "$line" -> value from line ${i-1}: "$apellidosCompound"');
      }
      // Fallback: look for singular forms - value is in PREVIOUS line
      else if (_containsVariation(line, 'NOMBRE') && nombresCompound == null && i - 1 >= 0) {
        nombresCompound = lines[i - 1].trim();
        log('OCR DEBUG: Found NOMBRE title at line $i: "$line" -> value from line ${i-1}: "$nombresCompound"');
      }
      else if (_containsVariation(line, 'APELLIDO') && apellidosCompound == null && i - 1 >= 0) {
        apellidosCompound = lines[i - 1].trim();
        log('OCR DEBUG: Found APELLIDO title at line $i: "$line" -> value from line ${i-1}: "$apellidosCompound"');
      }
    }
    
    // Try alternative extraction methods if initial search failed
    if (nombresCompound == null || apellidosCompound == null) {
      final alternativeNames = _extractNamesAlternative(lines);
      nombresCompound ??= alternativeNames['nombres'];
      apellidosCompound ??= alternativeNames['apellidos'];
    }
    
    // Clean and process the extracted compound names
    nombresCompound = _cleanExtractedText(nombresCompound);
    apellidosCompound = _cleanExtractedText(apellidosCompound);
    
    // Properly allocate names according to Colombian structure
    final nameAllocation = _allocateNames(nombresCompound, apellidosCompound);
    
    return {
      'firstName': nameAllocation['firstName'],      // Single or first name from NOMBRES
      'secondName': nameAllocation['secondName'],    // Second name from NOMBRES (if exists)
      'lastName': nameAllocation['lastName'],        // Compound apellidos or first apellido
      'nombresCompound': nombresCompound,            // Full NOMBRES from ID
      'apellidosCompound': apellidosCompound,        // Full APELLIDOS from ID
    };
  }
  
  bool _containsVariation(String line, String target) {
    // Check for exact match first
    if (line.contains(target)) return true;
    
    // Handle specific OCR errors we've observed
    final lineClean = line.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final targetClean = target.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    
    // Specific OCR error patterns
    final ocrErrorMap = {
      'NOMBRES': ['NOBRES', 'NOMES', 'NOMBRE', 'NMBRES'],
      'APELLIDOS': ['APELIDOS', 'APELLIDO', 'APLLIDOS', 'APELIDO'],
      'GRADO': ['CRADO', 'GADO', 'GRAD', 'GRADE'],
    };
    
    // Check if line contains any known OCR variants
    for (final entry in ocrErrorMap.entries) {
      if (entry.key == target) {
        for (final variant in entry.value) {
          if (lineClean.contains(variant)) {
            return true;
          }
        }
      }
    }
    
    // Check for partial matches (handling OCR errors)
    final similarity = _calculateStringSimilarity(lineClean, targetClean);
    if (similarity >= 0.6) return true; // Lowered threshold for better OCR tolerance
    
    // Check for substring matches
    final targetWords = target.split(' ');
    for (final word in targetWords) {
      if (word.length >= 3) { // Lowered from 4 to catch more matches
        final wordClean = word.replaceAll(RegExp(r'[^A-Z]'), '');
        if (lineClean.contains(wordClean.substring(0, (wordClean.length * 0.75).round()))) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  Map<String, String?> _extractNamesAlternative(List<String> lines) {
    // Alternative extraction method using patterns and context
    String? nombres;
    String? apellidos;
    
    final fullText = lines.join(' ').toUpperCase();
    
    // Look for patterns with regex
    final nombresPatterns = [
      RegExp(r'NOMBRES?[:\s]*([A-Z\s]+?)(?:APELLIDOS?|$)', caseSensitive: false),
      RegExp(r'NOMBRE[:\s]*([A-Z\s]+?)(?:APELLIDO|$)', caseSensitive: false),
    ];
    
    final apellidosPatterns = [
      RegExp(r'APELLIDOS?[:\s]*([A-Z\s]+?)(?:CEDULA|DOCUMENTO|FECHA|$)', caseSensitive: false),
      RegExp(r'APELLIDO[:\s]*([A-Z\s]+?)(?:CEDULA|DOCUMENTO|FECHA|$)', caseSensitive: false),
    ];
    
    // Try to extract nombres
    for (final pattern in nombresPatterns) {
      final match = pattern.firstMatch(fullText);
      if (match != null) {
        nombres = match.group(1)?.trim();
        break;
      }
    }
    
    // Try to extract apellidos
    for (final pattern in apellidosPatterns) {
      final match = pattern.firstMatch(fullText);
      if (match != null) {
        apellidos = match.group(1)?.trim();
        break;
      }
    }
    
    return {'nombres': nombres, 'apellidos': apellidos};
  }
  
  String? _cleanExtractedText(String? text) {
    if (text == null || text.isEmpty) return null;
    
    // Remove common OCR artifacts and clean up text
    String cleaned = text
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ')     // Normalize whitespace
        .trim()
        .toUpperCase();
    
    // Remove very short words that are likely OCR errors
    final words = cleaned.split(' ').where((word) => word.length >= 2).toList();
    
    return words.join(' ');
  }
  
  Map<String, String?> _allocateNames(String? nombresCompound, String? apellidosCompound) {
    // Allocate names according to Colombian naming convention
    String? firstName;
    String? secondName;
    String? lastName;
    
    // Process NOMBRES field (can be 1 or 2 names)
    if (nombresCompound != null && nombresCompound.isNotEmpty) {
      final nombres = nombresCompound.split(' ').where((name) => name.isNotEmpty).toList();
      
      if (nombres.isNotEmpty) {
        firstName = nombres[0]; // First name always goes to firstName
        
        if (nombres.length > 1) {
          secondName = nombres.sublist(1).join(' '); // Everything else is secondName
        }
      }
    }
    
    // Process APELLIDOS field (usually 2 last names, but we store as compound)
    if (apellidosCompound != null && apellidosCompound.isNotEmpty) {
      lastName = apellidosCompound; // Store full apellidos compound
    }
    
    return {
      'firstName': firstName,
      'secondName': secondName,
      'lastName': lastName,
    };
  }

  double _calculateDocumentConfidence({
    required bool hasMinistryHeader,
    required String? institution,
    required String? militaryRank,
    required String? identificationNumber,
    required Map<String, String?> names,
  }) {
    double confidence = 0.0;
    
    // CRITICAL ELEMENTS (High Priority) - 75% of total confidence
    
    // 1. MINISTERIO DE DEFENSA NACIONAL - Most critical (40%)
    if (hasMinistryHeader) {
      confidence += 0.40; // Increased from 0.30
    }
    
    // 2. Institution Name - Critical (20%)
    if (institution != null) {
      confidence += 0.20; // Decreased from 0.25 but still high priority
    }
    
    // 3. Names Match - Critical for identity verification (15%)
    final nombresPresent = names['nombresCompound']?.isNotEmpty == true;
    final apellidosPresent = names['apellidosCompound']?.isNotEmpty == true;
    
    if (nombresPresent && apellidosPresent) {
      confidence += 0.15; // Both nombres and apellidos found
    } else if (nombresPresent || apellidosPresent) {
      confidence += 0.10; // At least one name field found
    }
    
    // SECONDARY ELEMENTS (Medium Priority) - 20% of total confidence
    
    // 4. Military Rank - Important but secondary (15%)
    if (militaryRank != null && ColombianMilitaryRanks.getAllValidRanks().contains(militaryRank)) {
      confidence += 0.15; // Decreased from 0.25
    }
    
    // 5. ID Number - Supporting element (5%)
    if (identificationNumber != null && identificationNumber.length >= 8) {
      confidence += 0.05; // Decreased from 0.10
    }
    
    // BONUS CONFIDENCE for quality indicators
    
    // Bonus: If we have high-quality text extraction (compound names properly extracted)
    if (nombresPresent && apellidosPresent) {
      final nombresLength = names['nombresCompound']?.split(' ').length ?? 0;
      final apellidosLength = names['apellidosCompound']?.split(' ').length ?? 0;
      
      // Bonus for having multiple names (indicating good OCR quality)
      if (nombresLength >= 2 || apellidosLength >= 2) {
        confidence += 0.05; // Bonus for compound names
      }
    }
    
    return confidence.clamp(0.0, 1.0);
  }

  void dispose() {
    _textRecognizer.close();
  }
}