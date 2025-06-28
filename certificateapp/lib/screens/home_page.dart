import 'package:flutter/material.dart';
import 'certificate_form_page.dart';
import 'repository_page.dart';
import 'profile_page.dart';
import '../widgets/custom_navigation_bar.dart';
import '../models/certificate.dart';
import '../services/certificate_service.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  final List<Widget> _pages = [
    const CertificateListPage(),
    const DashboardPage(),
    const RepositoryPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userProfile = await _authService.getUserProfile(user.uid);
        debugPrint('User role: ${_userProfile?['role']}');
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    // Navigation logic for Home and Dashboard
    if (index == 0) {
      // Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      // Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else if (index == 2) {
      // Repository
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const RepositoryPage()),
      );
    } else if (index == 3) {
      // Profile
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : _pages[_selectedIndex],
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
      floatingActionButton: _shouldShowFAB() ? _buildFAB() : null,
    );
  }

  bool _shouldShowFAB() {
    if (_selectedIndex != 0) return false;

    final role = _userProfile?['role']?.toString().toLowerCase();
    // Show FAB for Recipients and Certificate Authorities
    return role == 'recipients' ||
        role == 'certificate authorities (cas)' ||
        role == 'admin';
  }

  Widget _buildFAB() {
    final role = _userProfile?['role']?.toString().toLowerCase();

    if (role == 'certificate authorities (cas)' || role == 'admin') {
      return FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CertificateFormPage()),
          );
          if (result == true && mounted) {
            setState(() {
              // This will trigger a rebuild of the CertificateListPage
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Issue Certificate'),
        elevation: 4,
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CertificateFormPage()),
          );
          if (result == true && mounted) {
            setState(() {
              // This will trigger a rebuild of the CertificateListPage
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Certificate'),
        elevation: 4,
      );
    }
  }
}

class CertificateListPage extends StatefulWidget {
  const CertificateListPage({super.key});

  @override
  State<CertificateListPage> createState() => _CertificateListPageState();
}

class _CertificateListPageState extends State<CertificateListPage> {
  final CertificateService _certificateService = CertificateService();
  final AuthService _authService = AuthService();
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Load user profile
      final user = _authService.currentUser;
      if (user != null) {
        _userProfile = await _authService.getUserProfile(user.uid);
      }

      // Load certificates
      final certificates = await _certificateService.getAllCertificates();
      if (mounted) {
        setState(() {
          _certificates = certificates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getWelcomeMessage() {
    final role = _userProfile?['role']?.toString().toLowerCase();
    final name = _userProfile?['displayName'] ?? 'User';

    switch (role) {
      case 'certificate authorities (cas)':
        return 'Welcome, $name! You can issue and manage certificates.';
      case 'recipients':
        return 'Welcome, $name! View and manage your certificates.';
      case 'admin':
        return 'Welcome, $name! You have full system access.';
      default:
        return 'Welcome, $name!';
    }
  }

  String _getPageTitle() {
    final role = _userProfile?['role']?.toString().toLowerCase();

    switch (role) {
      case 'certificate authorities (cas)':
        return 'Certificate Management';
      case 'recipients':
        return 'My Certificates';
      case 'admin':
        return 'System Certificates';
      default:
        return 'Digital Certificates';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _getPageTitle(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Welcome message
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWelcomeMessage(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${_userProfile?['role'] ?? 'Not specified'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _certificates.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No certificates yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add your first certificate',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final certificate = _certificates[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: CertificateCard(
                                certificate: certificate,
                                onTap: () {
                                  // TODO: Navigate to certificate details
                                },
                              ),
                            );
                          },
                          childCount: _certificates.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onTap;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if certificate is valid based on expiry date (1 year from upload)
    final isValid = certificate.uploadDate.isAfter(
      DateTime.now().subtract(const Duration(days: 365)),
    );
    final accentColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      certificate.fileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isValid
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isValid
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isValid ? Icons.verified : Icons.error,
                          size: 16,
                          color: isValid ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isValid ? 'Valid' : 'Invalid',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isValid ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _getFileTypeIcon(certificate.fileType),
                    size: 20,
                    color: accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    certificate.fileType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${certificate.fileSize} KB',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Uploaded: ${certificate.uploadDate.toString().split(' ')[0]}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (certificate.category != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      certificate.category!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
