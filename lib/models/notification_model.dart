// models/notification_model.dart
enum NotificationType {
  shopApproved,
  shopRejected,
}

class SellerNotification {
  final String id;
  final String sellerId;
  final String shopId;
  final String shopName;
  final NotificationType type;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  SellerNotification({
    required this.id,
    required this.sellerId,
    required this.shopId,
    required this.shopName,
    required this.type,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  SellerNotification copyWith({
    bool? isRead,
  }) {
    return SellerNotification(
      id: id,
      sellerId: sellerId,
      shopId: shopId,
      shopName: shopName,
      type: type,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}