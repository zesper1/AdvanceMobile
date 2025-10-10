// providers/notification_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<SellerNotification>> {
  NotificationNotifier() : super([]);

  void addNotification(SellerNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = [
      for (final notification in state)
        if (notification.id == notificationId)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
  }

  void markAllAsRead() {
    state = state.map((notification) => notification.copyWith(isRead: true)).toList();
  }

  void removeNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  List<SellerNotification> getNotificationsBySeller(String sellerId) {
    return state.where((notification) => notification.sellerId == sellerId).toList();
  }

  int getUnreadCount(String sellerId) {
    return state.where((notification) => 
      notification.sellerId == sellerId && !notification.isRead
    ).length;
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<SellerNotification>>((ref) {
  return NotificationNotifier();
});

final sellerNotificationsProvider = Provider.family<List<SellerNotification>, String>((ref, sellerId) {
  final allNotifications = ref.watch(notificationProvider);
  return allNotifications.where((notification) => notification.sellerId == sellerId).toList();
});

final unreadNotificationsCountProvider = Provider.family<int, String>((ref, sellerId) {
  final allNotifications = ref.watch(notificationProvider);
  return allNotifications.where((notification) => 
    notification.sellerId == sellerId && !notification.isRead
  ).length;
});