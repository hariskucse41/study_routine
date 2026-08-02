import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsRequested extends NotificationEvent {
  const LoadNotificationsRequested();
}

class RequestPermissionRequested extends NotificationEvent {
  const RequestPermissionRequested();
}

/// Dispatched internally by NotificationBloc's FCM foreground listener —
/// not intended to be added by the UI.
class ForegroundMessageReceived extends NotificationEvent {
  final RemoteMessage message;
  const ForegroundMessageReceived(this.message);
  @override
  List<Object?> get props => [message.messageId];
}
