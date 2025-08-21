import 'package:heroes_app/src/domain/models/colombian_military_ranks.dart';

enum VerificationStatus { approved, retryRequired, manualReview, failed }

class MilitaryIDData {
  final String? identificationNumber;
  final String? firstName;
  final String? lastName;
  final String? militaryRank;
  final String? institution;
  final bool hasMinistryHeader;
  final double documentConfidence;

  const MilitaryIDData({
    this.identificationNumber,
    this.firstName,
    this.lastName,
    this.militaryRank,
    this.institution,
    required this.hasMinistryHeader,
    required this.documentConfidence,
  });

  bool get isValidMilitaryDocument {
    return hasMinistryHeader &&
        institution != null &&
        militaryRank != null &&
        ColombianMilitaryRanks.isValidRankForInstitution(
            militaryRank!, institution!);
  }
}

class VerificationResult {
  final VerificationStatus status;
  final double matchScore;
  final List<FieldMismatch> mismatches;
  final int attemptNumber;
  final String? reason;
  final bool requiresManualReview;

  const VerificationResult({
    required this.status,
    required this.matchScore,
    required this.mismatches,
    required this.attemptNumber,
    this.reason,
    required this.requiresManualReview,
  });
}

class FieldMismatch {
  final String fieldName;
  final String userInput;
  final String ocrExtracted;
  final double similarity;

  const FieldMismatch({
    required this.fieldName,
    required this.userInput,
    required this.ocrExtracted,
    required this.similarity,
  });
}

class OCRResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final double confidence;

  const OCRResult({
    required this.success,
    this.data,
    this.error,
    required this.confidence,
  });
}