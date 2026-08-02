import 'package:equatable/equatable.dart';
import '../model/notification_item.dart';

enum NotificationLoadStatus { initial, loading, success, noPlan, error }

class NotificationState extends Equatable {
  final NotificationLoadStatus status;
  final List<NotificationItem> items;

  /// null = not yet asked this session.
  final bool? permissionGranted;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationLoadStatus.initial,
    this.items = const [],
    this.permissionGranted,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationLoadStatus? status,
    List<NotificationItem>? items,
    bool? permissionGranted,
    String? errorMessage,
  }) => NotificationState(
    status: status ?? this.status,
    items: items ?? this.items,
    permissionGranted: permissionGranted ?? this.permissionGranted,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, items, permissionGranted, errorMessage];
}
