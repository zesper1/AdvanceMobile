// widgets/notification_bell.dart - FIXED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart'; // ADD THIS IMPORT

class NotificationBell extends ConsumerStatefulWidget {
  final String sellerId;

  const NotificationBell({super.key, required this.sellerId});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  void _markAllAsRead() {
    ref.read(notificationProvider.notifier).markAllAsRead();
  }

  void _markAsRead(String notificationId) {
    ref.read(notificationProvider.notifier).markAsRead(notificationId);
  }

  @override
  Widget build(BuildContext context) {
    final notifications =
        ref.watch(sellerNotificationsProvider(widget.sellerId));
    final unreadCount =
        ref.watch(unreadNotificationsCountProvider(widget.sellerId));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          // Show notifications in a dialog so it isn't clipped by the AppBar
          showDialog(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 340,
                height: 440,
                child: _buildNotificationDropdown(notifications, unreadCount),
              ),
            ),
          );
        },
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications,
                color: Colors.black87,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDropdown(
      List<SellerNotification> notifications, int unreadCount) {
    return Container(
      width: 320,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyNotifications()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(SellerNotification notification) {
    final icon = notification.type == NotificationType.shopApproved
        ? Icons.check_circle
        : Icons.cancel;
    final color = notification.type == NotificationType.shopApproved
        ? Colors.green
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          notification.type == NotificationType.shopApproved
              ? 'Shop Approved'
              : 'Shop Rejected',
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.shopName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minLeadingWidth: 0,
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
