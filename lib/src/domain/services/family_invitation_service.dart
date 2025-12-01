import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'package:heroes_app/assets/app_constants.dart';

import 'package:heroes_app/src/domain/repositories/auth_service.dart';
import 'package:heroes_app/src/domain/repositories/firestore_service.dart';

class FamilyInvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final locator = GetIt.instance;

  Future<String> getOrCreateInviteCode() async {
    final authService = locator.get<AuthService>();
    final firestoreService = locator.get<FirestoreService>();
    final userCollection = locator.get<AppConstants>().usersCollection;
    final user = await authService.getUser();

    if (user == null) {
      throw Exception('User not found');
    }

    if (user.inviteCode != null && user.inviteCode!.isNotEmpty) {
      return user.inviteCode!;
    }

    String inviteCode;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    while (!isUnique && attempts < maxAttempts) {
      attempts++;
      inviteCode = _generateInviteCode();

      final existing =
          await _firestore
              .collection('users')
              .where('invite_code', isEqualTo: inviteCode)
              .limit(1)
              .get();

      if (existing.docs.isEmpty) {
        isUnique = true;
        await firestoreService.editDocumentById(
          userCollection,
          user.uid,
          'uid',
          {'invite_code': inviteCode, 'updated_at': Timestamp.now()},
        );

        return inviteCode;
      }
    }

    throw Exception(
      'Failed to generate unique invite code after $maxAttempts attempts',
    );
  }

  /// Generate random invite code in format: HEROES-ABC123
  String _generateInviteCode() {
    // Use only unambiguous characters (no 0/O, 1/I/l)
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code =
        List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    return 'HEROES-$code';
  }

  /// Validate invite code and return military user info
  /// Returns military user data if code is valid, null if invalid
  Future<Map<String, dynamic>?> validateInviteCode(String code) async {
    final query =
        await _firestore
            .collection('users')
            .where('invite_code', isEqualTo: code.toUpperCase().trim())
            .where('permission', isEqualTo: 'user') // Only military personnel
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    return {'uid': doc.id, ...doc.data()};
  }

  /// Create family relationship after beneficiary signs up with code
  /// Links beneficiary to military personnel and tracks relationship
  Future<void> createFamilyRelationship({
    required String inviteCode,
    required String militaryUid,
    required String beneficiaryUid,
    required String relationship,
    required String beneficiaryName,
  }) async {
    await _firestore.collection('family_relationships').add({
      'invitation_code': inviteCode,
      'primary_military_uid': militaryUid,
      'family_member_uid': beneficiaryUid,
      'family_member_name': beneficiaryName,
      'relationship': relationship, // spouse, child, parent
      'status': 'active',
      'created_at': Timestamp.now(),
      'accepted_at': Timestamp.now(),
    });
  }

  /// Get all family members for a military user
  Future<List<Map<String, dynamic>>> getFamilyMembers(
    String militaryUid,
  ) async {
    final query =
        await _firestore
            .collection('family_relationships')
            .where('primary_military_uid', isEqualTo: militaryUid)
            .where('status', isEqualTo: 'active')
            .orderBy('created_at', descending: true)
            .get();

    return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Get military personnel UID for a beneficiary
  /// Returns the UID of the military member who invited this beneficiary
  Future<String?> getPrimaryMilitaryUid(String beneficiaryUid) async {
    final query =
        await _firestore
            .collection('family_relationships')
            .where('family_member_uid', isEqualTo: beneficiaryUid)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return query.docs.first.data()['primary_military_uid'] as String?;
  }

  /// Get relationship info for a beneficiary
  Future<Map<String, dynamic>?> getBeneficiaryRelationship(
    String beneficiaryUid,
  ) async {
    final query =
        await _firestore
            .collection('family_relationships')
            .where('family_member_uid', isEqualTo: beneficiaryUid)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      return null;
    }

    final doc = query.docs.first;
    return {'id': doc.id, ...doc.data()};
  }

  /// Remove family relationship (revoke access)
  Future<void> removeFamilyMember(String relationshipId) async {
    await _firestore
        .collection('family_relationships')
        .doc(relationshipId)
        .update({'status': 'revoked', 'revoked_at': Timestamp.now()});
  }

  /// Get formatted relationship label in Spanish
  String getRelationshipLabel(String relationship) {
    switch (relationship) {
      case 'spouse':
        return 'Esposo/a';
      case 'child':
        return 'Hijo/a';
      case 'parent':
        return 'Padre/Madre';
      default:
        return relationship;
    }
  }
}
