import 'package:flutter/material.dart';
import '../models/user.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final User? currentUser;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUser?.isAdmin ?? false;
    final isCAVerifier = currentUser?.isCAVerifier ?? false;
    final showAdminNav = isAdmin || isCAVerifier;

    if (showAdminNav) {
      return NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          if (isAdmin || isCAVerifier)
            const NavigationDestination(
              icon: Icon(Icons.verified_user_outlined),
              selectedIcon: Icon(Icons.verified_user),
              label: 'CA Verification',
            ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          const NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Repository',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      );
    }

    // Regular user navigation
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Repository',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
