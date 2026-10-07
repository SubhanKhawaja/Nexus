import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus/features/auth/providers/auth_provider.dart';
import 'package:nexus/core/theme/app_colors.dart';

class UserAvatar extends ConsumerWidget {
  final double radius;

  const UserAvatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.photoURL!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.person, color: Colors.white, size: radius * 1.125),
    );
  }
}
