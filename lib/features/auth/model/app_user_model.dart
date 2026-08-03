import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? activeStudyPlanId;
  final int dailyStudyGoalMinutes;
  final String timezone;
  final String studyStartTime; // 'HH:mm'
  final String studyEndTime; // 'HH:mm'
  final String themeMode; // 'system' | 'light' | 'dark'
  final String language; // e.g. 'en'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.activeStudyPlanId,
    this.dailyStudyGoalMinutes = 120,
    this.timezone = 'Asia/Dhaka',
    this.studyStartTime = '08:00',
    this.studyEndTime = '22:00',
    this.themeMode = 'system',
    this.language = 'en',
    this.createdAt,
    this.updatedAt,
  });

  factory AppUserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      photoUrl: d['photoUrl'],
      activeStudyPlanId: d['activeStudyPlanId'],
      dailyStudyGoalMinutes: d['dailyStudyGoalMinutes'] ?? 120,
      timezone: d['timezone'] ?? 'Asia/Dhaka',
      studyStartTime: d['studyStartTime'] ?? '08:00',
      studyEndTime: d['studyEndTime'] ?? '22:00',
      themeMode: d['themeMode'] ?? 'system',
      language: d['language'] ?? 'en',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Fallback profile built straight from FirebaseAuth when the
  /// users/{uid} Firestore doc hasn't finished being written yet
  /// (e.g. a brief race right after registration).
  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'activeStudyPlanId': activeStudyPlanId,
    'dailyStudyGoalMinutes': dailyStudyGoalMinutes,
    'timezone': timezone,
    'studyStartTime': studyStartTime,
    'studyEndTime': studyEndTime,
    'themeMode': themeMode,
    'language': language,
    'updatedAt': FieldValue.serverTimestamp(),
    if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
  };

  AppUserModel copyWith({
    int? dailyStudyGoalMinutes,
    String? studyStartTime,
    String? studyEndTime,
    String? themeMode,
    String? language,
  }) => AppUserModel(
    uid: uid,
    name: name,
    email: email,
    photoUrl: photoUrl,
    activeStudyPlanId: activeStudyPlanId,
    dailyStudyGoalMinutes: dailyStudyGoalMinutes ?? this.dailyStudyGoalMinutes,
    timezone: timezone,
    studyStartTime: studyStartTime ?? this.studyStartTime,
    studyEndTime: studyEndTime ?? this.studyEndTime,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
