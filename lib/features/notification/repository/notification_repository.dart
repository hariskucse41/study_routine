import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/notification_preferences_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepository(this._firestore, this._auth);

  String get _uid => _auth.currentUser!.uid;

  DocumentReference get _doc =>
      _firestore.collection('notification_preferences').doc(_uid);

  /// Returns saved preferences, or in-memory defaults if the user hasn't
  /// saved any yet (no write happens here — Phase 12's Settings screen is
  /// what actually persists a doc, the first time the user changes a
  /// toggle).
  Future<NotificationPreferencesModel> fetchPreferences() async {
    final snapshot = await _doc.get();
    if (!snapshot.exists) {
      return NotificationPreferencesModel.defaultsFor(_uid);
    }
    return NotificationPreferencesModel.fromFirestore(snapshot);
  }

  Future<void> savePreferences(NotificationPreferencesModel preferences) {
    return _doc.set(preferences.toFirestore());
  }
}
