# Family Member Invitation System - Implementation Plan (Flutter App)

**Created:** January 27, 2025
**Status:** Planning Phase
**Target Start:** TBD (After Dashboard Implementation)
**Estimated Duration:** 2-3 days

---

## Executive Summary

Implement family member invitation functionality in the Flutter mobile app. Active military personnel can invite family members (spouse, parents, children, siblings) to join Héroes Colombia and access exclusive promotions. Family members register as "beneficiaries" and are automatically verified through the military member's invitation.

This implementation uses the same unified `invitations` collection created for the dashboard, with `invitation_type: "family_member"`.

---

## Architecture Overview

### Invitations Collection (Shared with Dashboard)

**Collection:** `invitations/{invitationId}`

```dart
// Family member invitation structure
{
  // Core Fields
  "id": String,
  "invitation_type": "family_member",  // Fixed value for family invitations
  "invited_email": String,
  "status": "pending" | "accepted" | "rejected" | "cancelled",

  // Sender Information (Military Personnel)
  "sender_uid": String,
  "sender_email": String,
  "sender_name": String,
  "inviter_military_id": String,  // identification_card
  "inviter_rank": String,          // e.g., "EJERCITO_OFICIALES_TENIENTE"

  // Family Specific
  "relationship": "spouse" | "parent" | "child" | "sibling",

  // Token & Security
  "invitation_token": String,  // UUID for email link

  // Acceptance Tracking
  "accepted_at": Timestamp?,
  "accepted_by_uid": String?,
  "rejected_at": Timestamp?,

  // Metadata
  "created_at": Timestamp,
  "updated_at": Timestamp,
  "last_reminder_sent_at": Timestamp?,
  "reminder_count": int?,
}
```

### User Document Updates (Beneficiary)

When a family member accepts an invitation:

```dart
{
  "uid": String,
  "email": String,
  "permission": "beneficiary",  // Auto-set for family members
  "user_type": "consumer",

  // Family member fields
  "first_name": String,
  "second_name": String?,
  "first_last_name": String,
  "second_last_name": String?,

  // Link to primary military personnel
  "primary_military_personnel_uid": String,  // sender_uid from invitation
  "relationship_to_primary": "spouse" | "parent" | "child" | "sibling",
  "invited_by_military_id": String,  // For verification

  // Auto-verification for family members
  "verified": true,
  "status": "active",

  // Standard fields
  "licence": "",  // Empty for family members
  "identification_card": "",  // Family members don't need military ID
  "rank": "OTROS_GRADOS_Beneficiarios",  // Fixed rank for beneficiaries
  "favourite_businesses": [],
  "device_notification_token": String?,

  "created_at": Timestamp,
  "updated_at": Timestamp,
}
```

---

## User Flow

```
Active Military Personnel (Flutter App)
  ↓
1. Opens Profile → "Invitar Familiar" button
  ↓
2. Fills form:
   - Email del familiar
   - Relación familiar (spouse/parent/child/sibling)
  ↓
3. Taps "Enviar Invitación"
  ↓
4. System creates invitation document in Firestore
  ↓
5. Backend sends email via Resend (Dashboard API/Cloud Function)
  ↓
6. Family member receives email with deep link
  ↓
7A. Has app → Opens link → Shows signup form (pre-filled with invitation)
7B. No app → Downloads app → Opens link → Shows signup form
  ↓
8. Family member fills signup form (name, password)
  ↓
9. System creates account:
   - permission: "beneficiary"
   - verified: true (auto-verified)
   - primary_military_personnel_uid: linked to inviter
  ↓
10. Auto-accepts invitation (marks as accepted)
  ↓
11. Family member logs in → Dashboard → Browse promotions
```

---

## Implementation Components

### 1. Domain Layer

#### File: `lib/src/domain/services/invitation_service.dart` (NEW)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  /// Create family member invitation
  Future<Map<String, dynamic>> createFamilyInvitation({
    required String inviterUid,
    required String inviterName,
    required String inviterEmail,
    required String inviterMilitaryId,
    required String inviterRank,
    required String invitedEmail,
    required String relationship,
  }) async {
    final invitationToken = _uuid.v4();

    final invitationData = {
      'invitation_type': 'family_member',
      'invited_email': invitedEmail.toLowerCase().trim(),
      'status': 'pending',

      'sender_uid': inviterUid,
      'sender_email': inviterEmail,
      'sender_name': inviterName,
      'inviter_military_id': inviterMilitaryId,
      'inviter_rank': inviterRank,

      'relationship': relationship,

      'invitation_token': invitationToken,

      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    };

    final docRef = await _firestore.collection('invitations').add(invitationData);

    // Trigger email sending (via Cloud Function or Dashboard API)
    // Note: This will be handled by Dashboard's email service
    await _triggerInvitationEmail(invitationToken, invitedEmail, inviterName, inviterRank, relationship);

    return {
      'id': docRef.id,
      'invitation_token': invitationToken,
      ...invitationData,
    };
  }

  /// Get pending invitations sent by current user
  Future<List<Map<String, dynamic>>> getSentInvitations(String senderUid) async {
    final snapshot = await _firestore
        .collection('invitations')
        .where('sender_uid', isEqualTo: senderUid)
        .where('invitation_type', isEqualTo: 'family_member')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  /// Get invitation by token (for acceptance flow)
  Future<Map<String, dynamic>?> getInvitationByToken(String token) async {
    final snapshot = await _firestore
        .collection('invitations')
        .where('invitation_token', isEqualTo: token)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
  }

  /// Accept invitation and link to primary military personnel
  Future<void> acceptInvitation(String invitationToken, String userUid) async {
    // Get invitation
    final invitation = await getInvitationByToken(invitationToken);
    if (invitation == null) {
      throw Exception('Invitación no encontrada o ya utilizada');
    }

    // Update invitation status
    await _firestore.collection('invitations').doc(invitation['id']).update({
      'status': 'accepted',
      'accepted_at': Timestamp.now(),
      'accepted_by_uid': userUid,
      'updated_at': Timestamp.now(),
    });

    // Update user document to link to primary military personnel
    await _firestore.collection('users').doc(userUid).update({
      'permission': 'beneficiary',
      'user_type': 'consumer',
      'primary_military_personnel_uid': invitation['sender_uid'],
      'relationship_to_primary': invitation['relationship'],
      'invited_by_military_id': invitation['inviter_military_id'],
      'verified': true,  // Auto-verify family members
      'status': 'active',
      'rank': 'OTROS_GRADOS_Beneficiarios',  // Fixed rank for beneficiaries
    });
  }

  /// Cancel invitation
  Future<void> cancelInvitation(String invitationId) async {
    await _firestore.collection('invitations').doc(invitationId).update({
      'status': 'cancelled',
      'updated_at': Timestamp.now(),
    });
  }

  /// Trigger email sending (calls Dashboard API endpoint)
  Future<void> _triggerInvitationEmail(
    String invitationToken,
    String invitedEmail,
    String inviterName,
    String inviterRank,
    String relationship,
  ) async {
    // Option 1: Call Dashboard API endpoint
    // POST /api/invitations/send-email
    // Body: { invitation_token, invited_email, inviter_name, inviter_rank, relationship }

    // Option 2: Cloud Function listens to invitations collection onCreate
    // and sends email automatically

    // For now, we'll rely on Dashboard's Cloud Function to handle this
    // No action needed here - the invitation document creation triggers the email
  }
}
```

---

### 2. Presentation Layer

#### File: `lib/src/presentation/pages/profile/invite_family_member_view.dart` (NEW)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/domain/services/invitation_service.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/locator.dart';

class InviteFamilyMemberView extends StatefulWidget {
  const InviteFamilyMemberView({Key? key}) : super(key: key);

  @override
  State<InviteFamilyMemberView> createState() => _InviteFamilyMemberViewState();
}

class _InviteFamilyMemberViewState extends State<InviteFamilyMemberView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedRelationship = 'spouse';
  bool _isLoading = false;

  final List<Map<String, String>> _relationships = [
    {'value': 'spouse', 'label': 'Esposo/a', 'icon': '💑'},
    {'value': 'child', 'label': 'Hijo/a', 'icon': '👶'},
    {'value': 'parent', 'label': 'Padre/Madre', 'icon': '👨‍👩‍👦'},
    {'value': 'sibling', 'label': 'Hermano/a', 'icon': '👫'},
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthCubit>().state.user;

      if (user == null) {
        throw Exception('Debes iniciar sesión para enviar invitaciones');
      }

      // Create invitation
      final invitationService = getIt<InvitationService>();
      await invitationService.createFamilyInvitation(
        inviterUid: user.uid,
        inviterName: '${user.firstName} ${user.firstLastName}',
        inviterEmail: user.email,
        inviterMilitaryId: user.identificationCard,
        inviterRank: user.rank,
        invitedEmail: _emailController.text.trim(),
        relationship: _selectedRelationship,
      );

      // Show success message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Invitación enviada a ${_emailController.text}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: ${e.toString()}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invitar Familiar'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Invita a tu familia a disfrutar de promociones exclusivas',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Email Input
                Text(
                  'Correo Electrónico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un correo';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24),

                // Relationship Selection
                Text(
                  'Relación Familiar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 12),

                // Relationship Cards
                ...(_relationships.map((rel) {
                  final isSelected = _selectedRelationship == rel['value'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRelationship = rel['value']!;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            rel['icon']!,
                            style: TextStyle(fontSize: 28),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              rel['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle, color: Colors.blue.shade600, size: 24),
                        ],
                      ),
                    ),
                  );
                }).toList()),

                SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendInvitation,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Enviar Invitación',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 16),

                // Info Text
                Center(
                  child: Text(
                    'Tu familiar recibirá un correo con instrucciones para registrarse',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

#### File: `lib/src/presentation/pages/profile/my_invitations_view.dart` (NEW)

Shows list of invitations sent by the user:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/domain/services/invitation_service.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:intl/intl.dart';

class MyInvitationsView extends StatefulWidget {
  const MyInvitationsView({Key? key}) : super(key: key);

  @override
  State<MyInvitationsView> createState() => _MyInvitationsViewState();
}

class _MyInvitationsViewState extends State<MyInvitationsView> {
  List<Map<String, dynamic>> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthCubit>().state.user;
      if (user == null) return;

      final invitationService = getIt<InvitationService>();
      final invitations = await invitationService.getSentInvitations(user.uid);

      if (!mounted) return;

      setState(() {
        _invitations = invitations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar invitaciones: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRelationshipLabel(String relationship) {
    switch (relationship) {
      case 'spouse':
        return 'Esposo/a';
      case 'child':
        return 'Hijo/a';
      case 'parent':
        return 'Padre/Madre';
      case 'sibling':
        return 'Hermano/a';
      default:
        return relationship;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'accepted':
        return 'Aceptada';
      case 'rejected':
        return 'Rechazada';
      case 'cancelled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Invitaciones'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadInvitations,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _invitations.length,
                    itemBuilder: (context, index) {
                      final invitation = _invitations[index];
                      return _buildInvitationCard(invitation);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.family_restroom, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'No has enviado invitaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Invita a tu familia para compartir beneficios',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    final status = invitation['status'] as String;
    final createdAt = (invitation['created_at'] as dynamic).toDate();
    final formattedDate = DateFormat('dd MMM yyyy').format(createdAt);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invitation['invited_email'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.family_restroom, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 6),
                Text(
                  _getRelationshipLabel(invitation['relationship']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

#### File: `lib/src/presentation/pages/auth/signup_with_invitation_view.dart` (NEW)

Handles signup for family members who click the invitation link:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroes_app/src/domain/services/invitation_service.dart';
import 'package:heroes_app/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:heroes_app/src/locator.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class SignupWithInvitationView extends StatefulWidget {
  final String invitationToken;

  const SignupWithInvitationView({
    Key? key,
    @PathParam('token') required this.invitationToken,
  }) : super(key: key);

  @override
  State<SignupWithInvitationView> createState() => _SignupWithInvitationViewState();
}

class _SignupWithInvitationViewState extends State<SignupWithInvitationView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _firstLastNameController = TextEditingController();
  final _secondLastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, dynamic>? _invitation;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInvitation();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _firstLastNameController.dispose();
    _secondLastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadInvitation() async {
    try {
      final invitationService = getIt<InvitationService>();
      final invitation = await invitationService.getInvitationByToken(widget.invitationToken);

      if (invitation == null) {
        if (!mounted) return;
        _showErrorAndExit('Invitación no válida o ya utilizada');
        return;
      }

      setState(() {
        _invitation = invitation;
        _emailController.text = invitation['invited_email'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showErrorAndExit('Error al cargar invitación: $e');
    }
  }

  void _showErrorAndExit(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authCubit = context.read<AuthCubit>();

      // Create user account with beneficiary permission
      await authCubit.signUpBeneficiary(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        secondName: _secondNameController.text.trim(),
        firstLastName: _firstLastNameController.text.trim(),
        secondLastName: _secondLastNameController.text.trim(),
      );

      // Wait for auth state
      final user = authCubit.state.user;
      if (user == null) {
        throw Exception('Error al crear cuenta');
      }

      // Accept invitation
      final invitationService = getIt<InvitationService>();
      await invitationService.acceptInvitation(widget.invitationToken, user.uid);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido a Héroes Colombia!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to dashboard
      context.router.replaceNamed('/dashboard');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_invitation == null) {
      return Scaffold(
        body: Center(
          child: Text('Invitación no válida'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Cuenta'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invitation Info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invitación de ${_invitation!['sender_name']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Completa tus datos para unirte a Héroes Colombia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Name Fields
                Text('Nombres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'Primer nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),

                SizedBox(height: 12),

                TextFormField(
                  controller: _secondNameController,
                  decoration: InputDecoration(
                    hintText: 'Segundo nombre (opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                SizedBox(height: 16),

                // Last Name Fields
                Text('Apellidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _firstLastNameController,
                  decoration: InputDecoration(
                    hintText: 'Primer apellido',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),

                SizedBox(height: 12),

                TextFormField(
                  controller: _secondLastNameController,
                  decoration: InputDecoration(
                    hintText: 'Segundo apellido (opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                SizedBox(height: 16),

                // Email (pre-filled, read-only)
                Text('Correo Electrónico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  readOnly: true,
                ),

                SizedBox(height: 16),

                // Password
                Text('Contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 6 caracteres',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'Requerido';
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### 3. Update Auth Cubit

Add method to sign up beneficiaries in `lib/src/presentation/cubits/auth/auth_cubit.dart`:

```dart
/// Sign up family member (beneficiary)
Future<void> signUpBeneficiary({
  required String email,
  required String password,
  required String firstName,
  required String secondName,
  required String firstLastName,
  required String secondLastName,
}) async {
  emit(state.copyWith(status: AuthStatus.loading));

  try {
    // Create Firebase Auth user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password,
    );

    // Create user document
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email.toLowerCase().trim(),
      'first_name': firstName,
      'second_name': secondName,
      'first_last_name': firstLastName,
      'second_last_name': secondLastName,
      'permission': 'beneficiary',  // Fixed for family members
      'user_type': 'consumer',
      'rank': 'OTROS_GRADOS_Beneficiarios',  // Fixed rank
      'licence': '',
      'identification_card': '',
      'verified': false,  // Will be set to true when invitation is accepted
      'status': 'pending',
      'favourite_businesses': [],
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    });

    // Fetch user data
    final user = await _getCurrentUser(userCredential.user!.uid);

    emit(state.copyWith(
      status: AuthStatus.userLoggedIn,
      user: user,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: AuthStatus.error,
      errorMessage: e.toString(),
    ));
  }
}
```

---

### 4. Deep Link Configuration

#### Android: `android/app/src/main/AndroidManifest.xml`

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <!-- Deep link for invitations -->
    <data
        android:scheme="https"
        android:host="heroescolombia.com"
        android:pathPrefix="/accept-invitation" />

    <data
        android:scheme="heroescolombia"
        android:host="invitation" />
</intent-filter>
```

#### iOS: `ios/Runner/Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>heroescolombia</string>
        </array>
    </dict>
</array>
```

---

### 5. Router Updates

Add route in `lib/src/config/router/app_router.dart`:

```dart
@MaterialAutoRouter(
  routes: <AutoRoute>[
    // ... existing routes

    // Invitation acceptance
    AutoRoute(
      page: SignupWithInvitationView,
      path: '/accept-invitation/:token',
    ),
  ],
)
class $AppRouter {}
```

---

### 6. Profile Page Updates

Add invitation button in `lib/src/presentation/pages/profile/profile_view.dart`:

```dart
// In profile options list
ListTile(
  leading: Icon(Icons.family_restroom, color: Theme.of(context).primaryColor),
  title: Text('Invitar Familiar'),
  subtitle: Text('Comparte beneficios con tu familia'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InviteFamilyMemberView()),
    );
  },
),

ListTile(
  leading: Icon(Icons.mail_outline, color: Theme.of(context).primaryColor),
  title: Text('Mis Invitaciones'),
  subtitle: Text('Ver invitaciones enviadas'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyInvitationsView()),
    );
  },
),
```

---

### 7. Dependency Registration

Add to `lib/src/locator.dart`:

```dart
void setupLocator() {
  // ... existing registrations

  // Invitation Service
  getIt.registerLazySingleton<InvitationService>(() => InvitationService());
}
```

---

## Testing Checklist

### Family Invitation Flow
- [ ] Military user can open "Invite Family" screen
- [ ] Form validation works (email, relationship)
- [ ] Invitation created in Firestore
- [ ] Email sent to family member (via Dashboard/Cloud Function)
- [ ] Deep link opens app correctly
- [ ] Signup form pre-fills email
- [ ] Account created as beneficiary
- [ ] Invitation auto-accepted
- [ ] User linked to primary military personnel
- [ ] User auto-verified and activated
- [ ] Family member can browse promotions

### Invitation Management
- [ ] User can view sent invitations
- [ ] Pending invitations show correct status
- [ ] Accepted invitations update status
- [ ] User can cancel pending invitations

---

## Dependencies to Add

Add to `pubspec.yaml`:

```yaml
dependencies:
  uuid: ^4.0.0  # For generating invitation tokens
  intl: ^0.18.0  # For date formatting
  # ... existing dependencies
```

---

## Implementation Timeline

### Day 1: Core Services & Models
- ✅ Create InvitationService
- ✅ Update User model with family fields
- ✅ Add signUpBeneficiary to AuthCubit
- ✅ Test invitation creation

### Day 2: UI & Flow
- ✅ Create InviteFamilyMemberView
- ✅ Create MyInvitationsView
- ✅ Create SignupWithInvitationView
- ✅ Update Profile page
- ✅ Configure deep links

### Day 3: Testing & Integration
- ✅ Test complete invitation flow
- ✅ Test deep link handling
- ✅ Test auto-verification
- ✅ Test family member permissions
- ✅ Integration with Dashboard email service

---

## Success Metrics

- ✅ Military personnel can invite family members
- ✅ Invitations delivered via email
- ✅ Deep links work on iOS and Android
- ✅ Family members successfully register
- ✅ Auto-verification works
- ✅ Family members can access all promotions
- ✅ Invitation acceptance rate tracked

---

## Future Enhancements

1. **Multiple Family Members**
   - Track all family members per military user
   - Family member list view

2. **Verification Proof**
   - Optional family member ID verification
   - Proof of relationship (marriage certificate, etc.)

3. **Family Benefits Dashboard**
   - Show savings across all family members
   - Combined analytics

4. **Invitation Templates**
   - Custom invitation messages
   - Personalized emails

---

**Ready to implement after Dashboard invitation system is complete! 🚀**
