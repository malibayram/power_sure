import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _currentUserOrgId;
  String? _userRole;
  bool _isModerator = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _currentUserOrgId = userData.data()?['organizationId'];
          _userRole = userData.data()?['role'];
          _isModerator = userData.data()?['isModerator'] ?? false;
        });
      }
    }
  }

  Future<void> _updateUserRole(
      String userId, String newRole, String currentRole) async {
    // Don't allow changing admin roles
    if (currentRole == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin roles cannot be modified'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Organization admins can only modify regular users and suppliers
    if (_userRole == 'organization_admin' &&
        (currentRole == 'organization_admin' ||
            newRole == 'organization_admin' ||
            newRole == 'admin')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission for this action'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'role': newRole});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User role updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmUser(String userId) async {
    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isConfirmed': true});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User confirmed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to confirm user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleModerator(String userId, bool newValue) async {
    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isModerator': newValue});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'User ${newValue ? 'promoted to' : 'removed from'} moderator role'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update moderator status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userRole == 'admin'
            ? _firestore.collection('users').snapshots()
            : _firestore
                .collection('users')
                .where('organizationId', isEqualTo: _currentUserOrgId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final currentRole = userData['role'] ?? 'client';
              final isCurrentUser =
                  userId == FirebaseAuth.instance.currentUser?.uid;
              final isAdmin = currentRole == 'admin';
              final isOrgAdmin = currentRole == 'organization_admin';
              final isModerator = userData['isModerator'] ?? false;
              final isConfirmed = userData['isConfirmed'] ?? false;

              // Determine if current user can modify this user
              final canModify = !isCurrentUser &&
                  (_userRole == 'admin' ||
                      (_userRole == 'organization_admin' &&
                          !isAdmin &&
                          !isOrgAdmin));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text('${userData['name']} ${userData['surname']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${userData['email']}'),
                      Text('Phone: ${userData['phone']}'),
                      Text(
                        'Role: $currentRole${isModerator ? ' (Moderator)' : ''}',
                        style: TextStyle(
                          fontWeight: (isAdmin || isOrgAdmin || isModerator)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isAdmin
                              ? Colors.blue
                              : isOrgAdmin
                                  ? Colors.purple
                                  : isModerator
                                      ? Colors.green
                                      : null,
                        ),
                      ),
                      if (!isConfirmed)
                        const Text(
                          'Pending Confirmation',
                          style: TextStyle(
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: canModify
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isConfirmed &&
                                (_userRole == 'admin' ||
                                    _userRole == 'organization_admin'))
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () => _confirmUser(userId),
                                tooltip: 'Confirm User',
                              ),
                            if (_userRole == 'admin')
                              IconButton(
                                icon: Icon(
                                  isModerator ? Icons.star : Icons.star_border,
                                  color: isModerator ? Colors.amber : null,
                                ),
                                onPressed: () {
                                  _toggleModerator(userId, !isModerator);
                                },
                              ),
                            PopupMenuButton<String>(
                              onSelected: (String role) {
                                _updateUserRole(userId, role, currentRole);
                              },
                              itemBuilder: (BuildContext context) {
                                final List<PopupMenuItem<String>> items = [];

                                if (_userRole == 'admin') {
                                  items.add(const PopupMenuItem(
                                    value: 'organization_admin',
                                    child: Text('Make Organization Admin'),
                                  ));
                                }

                                items.addAll([
                                  const PopupMenuItem(
                                    value: 'supplier',
                                    child: Text('Make Supplier'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'client',
                                    child: Text('Make Client'),
                                  ),
                                ]);

                                return items;
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
