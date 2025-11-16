/// Utility Functions and Helpers for USSD Admin App
/// This file contains reusable helper functions for formatting,
/// validation, and common operations used throughout the app.

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// DATE & TIME FORMATTING
// =============================================================================

class DateFormatters {
  /// Format DateTime to "MMM dd, yyyy" (e.g., "Jan 15, 2025")
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format DateTime to "MMM dd, yyyy HH:mm" (e.g., "Jan 15, 2025 14:30")
  static String formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  /// Format DateTime to time only "HH:mm" (e.g., "14:30")
  static String formatTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('HH:mm').format(date);
  }

  /// Format DateTime to relative time (e.g., "2 hours ago", "Yesterday")
  static String formatRelative(DateTime? date) {
    if (date == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(date);
    }
  }

  /// Get date 7 days ago for default filters
  static DateTime get sevenDaysAgo {
    return DateTime.now().subtract(const Duration(days: 7));
  }

  /// Get date 30 days ago for default filters
  static DateTime get thirtyDaysAgo {
    return DateTime.now().subtract(const Duration(days: 30));
  }

  /// Get start of current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Get end of current month
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }
}

// =============================================================================
// CURRENCY & NUMBER FORMATTING
// =============================================================================

class CurrencyFormatters {
  /// Format number as currency with GHS symbol
  static String formatGHS(double? amount, {int decimals = 2}) {
    if (amount == null) return 'GHS 0.00';
    final formatter = NumberFormat.currency(
      symbol: 'GHS ',
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  /// Format number as compact currency (e.g., "GHS 1.2K", "GHS 3.5M")
  static String formatCompactGHS(double? amount) {
    if (amount == null) return 'GHS 0';
    
    if (amount >= 1000000) {
      return 'GHS ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'GHS ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return formatGHS(amount);
    }
  }

  /// Format percentage
  static String formatPercentage(double? value, {int decimals = 1}) {
    if (value == null) return '0%';
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format number with thousand separators
  static String formatNumber(num? number, {int decimals = 0}) {
    if (number == null) return '0';
    final formatter = NumberFormat('#,##0${decimals > 0 ? '.${'0' * decimals}' : ''}');
    return formatter.format(number);
  }
}

// =============================================================================
// VALIDATION HELPERS
// =============================================================================

class Validators {
  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validate phone number (Ghana format)
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Ghana phone numbers: 10 digits starting with 0, or 12 digits starting with 233
    if (!RegExp(r'^(0\d{9}|233\d{9})$').hasMatch(cleaned)) {
      return 'Please enter a valid Ghana phone number';
    }
    
    return null;
  }

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate number range
  static String? numberInRange(
    double? value,
    double min,
    double max, {
    String fieldName = 'Value',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }
    if (value < min || value > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }

  /// Validate amount (min/max for payment types)
  static String? amount(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (min != null && amount < min) {
      return 'Amount must be at least ${CurrencyFormatters.formatGHS(min)}';
    }
    
    if (max != null && amount > max) {
      return 'Amount must not exceed ${CurrencyFormatters.formatGHS(max)}';
    }
    
    return null;
  }
}

// =============================================================================
// STATUS HELPERS
// =============================================================================

class StatusHelpers {
  /// Get color for transaction status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'active':
        return const Color(0xFF36C577); // AppColors.success
      case 'pending':
      case 'processing':
        return const Color(0xFFE9B44C); // AppColors.warning
      case 'failed':
      case 'error':
      case 'cancelled':
      case 'inactive':
        return const Color(0xFFFF4D4F); // AppColors.error
      default:
        return const Color(0xFF8A8E9B); // AppColors.textTertiary
    }
  }

  /// Get icon for transaction status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'active':
        return Icons.check_circle;
      case 'pending':
      case 'processing':
        return Icons.pending;
      case 'failed':
      case 'error':
        return Icons.error;
      case 'cancelled':
      case 'inactive':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  /// Format status text for display
  static String formatStatus(String status) {
    return status.substring(0, 1).toUpperCase() + 
           status.substring(1).toLowerCase();
  }

  /// Get subscription status badge widget
  static Widget buildStatusBadge(String status) {
    final color = getStatusColor(status);
    final icon = getStatusIcon(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            formatStatus(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DIALOG HELPERS
// =============================================================================

class DialogHelpers {
  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDanger
                ? ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4F),
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF36C577)),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF242730), // AppColors.surfaceHigh
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Color(0xFFFF4D4F)),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF242730),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Color(0xFF4A9EFF)),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF242730),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show loading dialog
  static void showLoading(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

// =============================================================================
// ERROR HANDLING
// =============================================================================

class ErrorHandlers {
  /// Extract user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    // DioException handling
    if (error.toString().contains('DioException')) {
      if (error.toString().contains('Network')) {
        return 'Network error. Please check your connection.';
      }
      if (error.toString().contains('timeout')) {
        return 'Request timeout. Please try again.';
      }
      if (error.toString().contains('401')) {
        return 'Unauthorized. Please log in again.';
      }
      if (error.toString().contains('403')) {
        return 'Access denied. You do not have permission.';
      }
      if (error.toString().contains('404')) {
        return 'Resource not found.';
      }
      if (error.toString().contains('500')) {
        return 'Server error. Please try again later.';
      }
    }
    
    // Try to extract message from error
    final errorStr = error.toString();
    if (errorStr.contains('Exception: ')) {
      return errorStr.split('Exception: ').last;
    }
    
    return errorStr;
  }

  /// Handle API error and show snackbar
  static void handleError(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    DialogHelpers.showError(context, message);
  }
}

// =============================================================================
// ROLE CHECKING
// =============================================================================

class RoleHelpers {
  /// Check if user is super admin
  static Future<bool> isSuperAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'org_admin';
    return role == 'super_admin';
  }

  /// Get current user role
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role') ?? 'org_admin';
  }

  /// Get current user token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}

// =============================================================================
// CHART HELPERS
// =============================================================================

class ChartHelpers {
  /// Get color for chart data point
  static Color getChartColor(int index) {
    const colors = [
      Color(0xFFFF8A3D), // chart1
      Color(0xFF3A7FA5), // chart2
      Color(0xFF36C577), // chart3
      Color(0xFFE9B44C), // chart4
      Color(0xFFFF4D4F), // chart5
      Color(0xFF4A9EFF), // chart6
    ];
    return colors[index % colors.length];
  }

  /// Format large numbers for chart labels
  static String formatChartValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}
