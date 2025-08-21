import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_enums.dart';
import 'package:heroes_app/src/domain/models/verification_models.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';
import 'package:heroes_app/src/domain/services/military_id_ocr_service.dart';
import 'package:image_picker/image_picker.dart';

class MilitaryVerificationService {
  static const double approvalThreshold = 0.80;
  static const double retryThreshold = 0.50;
  static const int maxAttempts = 3;

  final MilitaryIDOCRService _ocrService = MilitaryIDOCRService();
  final FirestoreService _firestoreService = GetIt.instance.get<FirestoreService>();

  Future<VerificationResult> verifyMilitaryIdentity({
    required Map<String, String> userEnteredData,
    required XFile militaryIdImage,
    required String userId,
    required int attemptNumber,
  }) async {
    try {
      final ocrResult = await _ocrService.extractMilitaryIDData(militaryIdImage);

      if (!ocrResult.success || ocrResult.data == null) {
        return VerificationResult(
          status: VerificationStatus.failed,
          matchScore: ocrResult.data?.documentConfidence ?? 0.0,
          mismatches: [],
          attemptNumber: attemptNumber,
          reason: ocrResult.error ?? 'No se pudo procesar el documento militar',
          requiresManualReview: false,
        );
      }

      final militaryData = ocrResult.data!;

      if (!militaryData.isValidMilitaryDocument) {
        return VerificationResult(
          status: VerificationStatus.failed,
          matchScore: militaryData.documentConfidence,
          mismatches: [],
          attemptNumber: attemptNumber,
          reason: 'Debe usar un documento militar oficial del Ministerio de Defensa Nacional',
          requiresManualReview: false,
        );
      }

      final comparison = _compareUserDataWithMilitaryID(userEnteredData, militaryData);
      final matchScore = _calculateOverallScore(comparison, militaryData);

      final status = _determineVerificationStatus(matchScore, attemptNumber);
      
      // Only store verification attempt if it requires manual review
      // (either explicit manual review or max attempts reached)
      if (status == VerificationStatus.manualReview) {
        await _storeVerificationAttempt(
            userId, userEnteredData, militaryData, comparison, matchScore, attemptNumber);
      }

      await _handleVerificationOutcome(userId, status, matchScore);

      return VerificationResult(
        status: status,
        matchScore: matchScore,
        mismatches: comparison.where((m) => m.similarity < 0.8).toList(),
        attemptNumber: attemptNumber,
        reason: _getStatusReason(status, matchScore),
        requiresManualReview: status == VerificationStatus.manualReview,
      );
    } catch (e) {
      log('Error in verifyMilitaryIdentity: $e');
      await _updateUserStatus(userId, UserStatus.pending);
      return VerificationResult(
        status: VerificationStatus.failed,
        matchScore: 0.0,
        mismatches: [],
        attemptNumber: attemptNumber,
        reason: 'Error técnico: ${e.toString()}',
        requiresManualReview: true,
      );
    }
  }

  List<FieldMismatch> _compareUserDataWithMilitaryID(
      Map<String, String> userData, MilitaryIDData militaryData) {
    final mismatches = <FieldMismatch>[];

    // Enhanced name comparison for Colombian military IDs
    // Form has: first_name + second_name + first_last_name + second_last_name
    // ID has: NOMBRES (compound) + APELLIDOS (compound)
    
    // Compare NOMBRES (first_name + second_name from form vs firstName from ID)
    // Note: militaryData.firstName now contains the properly allocated firstName from NOMBRES
    if (userData['first_name'] != null && militaryData.firstName != null) {
      final similarity = _calculateStringSimilarity(userData['first_name']!, militaryData.firstName!);
      
      mismatches.add(FieldMismatch(
        fieldName: 'first_name',
        userInput: userData['first_name']!,
        ocrExtracted: militaryData.firstName!,
        similarity: similarity,
      ));
    }

    // Compare compound APELLIDOS (first_last_name + second_last_name from form vs lastName from ID)
    // Note: militaryData.lastName now contains the full apellidos compound
    if (militaryData.lastName != null) {
      final userApellidos = _buildCompoundLastNames(userData);
      final similarity = _calculateStringSimilarity(userApellidos, militaryData.lastName!);
      
      mismatches.add(FieldMismatch(
        fieldName: 'apellidos_compound',
        userInput: userApellidos,
        ocrExtracted: militaryData.lastName!,
        similarity: similarity,
      ));
    }
    
    // Also do individual name comparisons for detailed feedback
    _addIndividualNameComparisons(userData, militaryData, mismatches);

    if (userData['identification_card'] != null && militaryData.identificationNumber != null) {
      final similarity = _calculateStringSimilarity(
          userData['identification_card']!, militaryData.identificationNumber!);
      mismatches.add(FieldMismatch(
        fieldName: 'identification',
        userInput: userData['identification_card']!,
        ocrExtracted: militaryData.identificationNumber!,
        similarity: similarity,
      ));
    }

    return mismatches;
  }

  // Helper methods for enhanced name comparison
  String _buildCompoundLastNames(Map<String, String> userData) {
    // Build compound "apellidos" from form: first_last_name + second_last_name
    final firstLastName = userData['first_last_name']?.trim() ?? '';
    final secondLastName = userData['second_last_name']?.trim() ?? '';
    
    return [firstLastName, secondLastName]
        .where((name) => name.isNotEmpty)
        .join(' ')
        .toUpperCase();
  }
  
  void _addIndividualNameComparisons(
    Map<String, String> userData, 
    MilitaryIDData militaryData, 
    List<FieldMismatch> mismatches
  ) {
    // Individual comparisons for detailed analysis
    
    // First name comparison (less critical but useful for debugging)
    if (userData['first_name'] != null && militaryData.firstName != null) {
      final similarity = _calculateStringSimilarity(
          userData['first_name']!, militaryData.firstName!);
      
      mismatches.add(FieldMismatch(
        fieldName: 'first_name_individual',
        userInput: userData['first_name']!,
        ocrExtracted: militaryData.firstName!,
        similarity: similarity,
      ));
    }
    
    // First last name comparison
    if (userData['first_last_name'] != null && militaryData.lastName != null) {
      final similarity = _calculateStringSimilarity(
          userData['first_last_name']!, militaryData.lastName!);
      
      mismatches.add(FieldMismatch(
        fieldName: 'first_last_name_individual',
        userInput: userData['first_last_name']!,
        ocrExtracted: militaryData.lastName!,
        similarity: similarity,
      ));
    }
  }

  double _calculateStringSimilarity(String str1, String str2) {
    if (str1.isEmpty && str2.isEmpty) return 1.0;
    if (str1.isEmpty || str2.isEmpty) return 0.0;

    final cleanStr1 = str1.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final cleanStr2 = str2.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (cleanStr1 == cleanStr2) return 1.0;
    if (cleanStr1.contains(cleanStr2) || cleanStr2.contains(cleanStr1)) return 0.8;

    final longerLength = cleanStr1.length > cleanStr2.length ? cleanStr1.length : cleanStr2.length;
    final editDistance = _levenshteinDistance(cleanStr1, cleanStr2);

    return (longerLength - editDistance) / longerLength;
  }

  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  double _calculateOverallScore(List<FieldMismatch> comparison, MilitaryIDData militaryData) {
    if (comparison.isEmpty) return militaryData.documentConfidence;

    final averageFieldSimilarity = comparison.map((m) => m.similarity).reduce((a, b) => a + b) / comparison.length;

    return (militaryData.documentConfidence * 0.6) + (averageFieldSimilarity * 0.4);
  }

  VerificationStatus _determineVerificationStatus(double matchScore, int attemptNumber) {
    if (matchScore >= approvalThreshold) {
      return VerificationStatus.approved;
    } else if (matchScore >= retryThreshold && attemptNumber < maxAttempts) {
      return VerificationStatus.retryRequired;
    } else {
      return VerificationStatus.manualReview;
    }
  }

  Future<void> _storeVerificationAttempt(
    String userId,
    Map<String, String> userEnteredData,
    MilitaryIDData militaryData,
    List<FieldMismatch> comparison,
    double matchScore,
    int attemptNumber,
  ) async {
    try {
      final attemptData = {
        'user_id': userId,
        'attempt_number': attemptNumber,
        'timestamp': DateTime.now().toIso8601String(),
        'match_score': matchScore,
        'user_data': userEnteredData,
        'ocr_extracted': {
          'identification_number': militaryData.identificationNumber,
          'first_name': militaryData.firstName,
          'last_name': militaryData.lastName,
          'military_rank': militaryData.militaryRank,
          'institution': militaryData.institution,
          'has_ministry_header': militaryData.hasMinistryHeader,
          'document_confidence': militaryData.documentConfidence,
        },
        'field_comparisons': comparison.map((m) => {
          'field_name': m.fieldName,
          'user_input': m.userInput,
          'ocr_extracted': m.ocrExtracted,
          'similarity': m.similarity,
        }).toList(),
      };

      await _firestoreService.createDocument('verification_attempts', attemptData);
    } catch (e) {
      log('Error storing verification attempt: $e');
    }
  }

  Future<void> _handleVerificationOutcome(
      String userId, VerificationStatus status, double matchScore) async {
    UserStatus userStatus;
    switch (status) {
      case VerificationStatus.approved:
        userStatus = UserStatus.active;
        break;
      case VerificationStatus.retryRequired:
        userStatus = UserStatus.pending;
        break;
      case VerificationStatus.manualReview:
        userStatus = UserStatus.manualReview;
        break;
      case VerificationStatus.failed:
        userStatus = UserStatus.pending;
        break;
    }

    await _updateUserStatus(userId, userStatus);
  }

  Future<void> _updateUserStatus(String userId, UserStatus status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
      };
      
      // If user is approved, also set verified to true
      if (status == UserStatus.active) {
        updateData['verified'] = true;
      }
      
      await _firestoreService.editDocumentById(
        'users',
        userId,
        'uid',
        updateData,
      );
    } catch (e) {
      log('Error updating user status: $e');
    }
  }

  String _getStatusReason(VerificationStatus status, double matchScore) {
    switch (status) {
      case VerificationStatus.approved:
        return 'Documento militar verificado exitosamente';
      case VerificationStatus.retryRequired:
        return 'Algunos datos no coinciden exactamente. Puedes intentar nuevamente.';
      case VerificationStatus.manualReview:
        return 'Documento requiere revisión manual por nuestro equipo';
      case VerificationStatus.failed:
        return 'No se pudo verificar el documento';
    }
  }

  void dispose() {
    _ocrService.dispose();
  }
}