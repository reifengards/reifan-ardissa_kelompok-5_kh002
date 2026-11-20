import 'package:flutter/material.dart';

import 'models/admin.dart';
import 'models/user.dart';
import 'services/admin_service.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User dan Admin',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const CrudHomePage(),
    );
  }
}

class CrudHomePage extends StatefulWidget {
  const CrudHomePage({super.key});

  @override
  State<CrudHomePage> createState() => _CrudHomePageState();
}

class _CrudHomePageState extends State<CrudHomePage> {
  final ApiService _apiService = ApiService();
  final AdminService _adminService = AdminService();
  final TextEditingController _adminIdController = TextEditingController(
    text: '$adminId',
  );

  List<User> _users = [];
  List<Admin> _admins = [];
  int _selectedUserId = userId;
  bool _loadingUsers = true;
  bool _loadingAdmins = true;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadAdmins();
  }

  @override
  void dispose() {
    _adminIdController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade700 : null,
        ),
      );
  }

  Future<void> _loadUsers() async {
    setState(() => _loadingUsers = true);
    try {
      final users = await _apiService.getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        if (!_users.any((user) => user.id == _selectedUserId) &&
            users.isNotEmpty) {
          _selectedUserId = users.first.id;
        }
      });
    } catch (error) {
      _showMessage('Gagal memuat User: $error', isError: true);
    } finally {
      if (mounted) setState(() => _loadingUsers = false);
    }
  }

  Future<void> _loadAdmins() async {
    setState(() => _loadingAdmins = true);
    try {
      final admins = await _adminService.getAdmins();
      if (!mounted) return;
      setState(() => _admins = admins);
    } catch (error) {
      _showMessage('Gagal memuat Admin: $error', isError: true);
    } finally {
      if (mounted) setState(() => _loadingAdmins = false);
    }
  }

  Future<void> _runAction<T>(
    Future<T> Function() action,
    void Function(T result) onSuccess,
    String successMessage,
  ) async {
    setState(() => _working = true);
    try {
      final result = await action();
      if (!mounted) return;
      setState(() => onSuccess(result));
      _showMessage(successMessage);
    } catch (error) {
      _showMessage('Operasi gagal: $error', isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  User _userForAction() {
    final index = _users.indexWhere((user) => user.id == _selectedUserId);
    if (index >= 0) return _users[index];
    return User(
      id: _selectedUserId,
      name: 'User $_selectedUserId',
      email: 'user$_selectedUserId@example.com',
      city: '',
    );
  }

  void _upsertUser(User user, {String? cityFallback}) {
    final oldIndex = _users.indexWhere((item) => item.id == user.id);
    final updated = User(
      id: user.id,
      name: user.name,
      email: user.email,
      city: user.city.isEmpty ? (cityFallback ?? '') : user.city,
    );
    if (oldIndex == -1) {
      _users.insert(0, updated);
    } else {
      _users[oldIndex] = updated;
    }
  }

  Future<void> _createUser() async {
    final user = User(
      id: userId,
      name: 'User Praktikum',
      email: 'user$userId@example.com',
      city: 'Jakarta',
    );
    await _runAction(() => _apiService.createUser(user), (created) {
      _upsertUser(created, cityFallback: user.city);
    }, 'User ID $userId berhasil ditambahkan.');
  }

  Future<void> _updateUserPut() async {
    final current = _userForAction();
    final name = '${current.name} (Updated)';
    final email = 'updated.${current.id}@example.com';
    await _runAction(
      () => _apiService.updateUserPut(current.id, name, email),
      (updated) => _upsertUser(updated, cityFallback: current.city),
      'User ID ${current.id} berhasil diperbarui dengan PUT.',
    );
  }

  Future<void> _updateUserPatch() async {
    final current = _userForAction();
    await _runAction(
      () => _apiService.updateUserPatch(current.id, current.name),
      (updated) => _upsertUser(updated, cityFallback: current.city),
      'Nama User ID ${current.id} berhasil diperbarui dengan PATCH.',
    );
  }

  Future<void> _deleteUser() async {
    final id = _selectedUserId;
    await _runAction(
      () => _apiService.deleteUser(id),
      (_) => _users.removeWhere((user) => user.id == id),
      'User ID $id berhasil dihapus.',
    );
  }

  Future<void> _showUserDetails(User user) async {
    try {
      final detail = user.id == userId
          ? user
          : await _apiService.getUser(user.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Detail User #${detail.id}'),
          content: _DetailsContent(
            name: detail.name,
            email: detail.email,
            extraLabel: 'Kota',
            extraValue: detail.city,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (error) {
      _showMessage('Gagal memuat detail User: $error', isError: true);
    }
  }

  int? _readAdminId() {
    final id = int.tryParse(_adminIdController.text.trim());
    if (id == null || id <= 0) {
      _showMessage('Masukkan ID Admin berupa bilangan positif.', isError: true);
      return null;
    }
    return id;
  }

  Future<void> _showAdminDetails([int? requestedId]) async {
    final id = requestedId ?? _readAdminId();
    if (id == null) return;
    if (requestedId != null) _adminIdController.text = '$requestedId';
    setState(() => _working = true);
    try {
      final admin = await _adminService.getAdmin(id);
      if (!mounted) return;
      _showMessage('Detail Admin ID $id berhasil dimuat.');
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Detail Admin #${admin.id}'),
          content: _DetailsContent(
            name: admin.name,
            email: admin.email,
            extraLabel: 'Departemen',
            extraValue: admin.department,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (error) {
      _showMessage('Gagal memuat detail Admin: $error', isError: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _deleteAdmin() async {
    final id = _readAdminId();
    if (id == null) return;
    await _runAction(
      () => _adminService.deleteAdmin(id),
      (_) => _admins.removeWhere((admin) => admin.id == id),
      'Admin ID $id berhasil dihapus.',
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aksi untuk User #$_selectedUserId',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _working ? null : _createUser,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('POST'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _working ? null : _updateUserPut,
                      icon: const Icon(Icons.edit),
                      label: const Text('PUT'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _working ? null : _updateUserPatch,
                      icon: const Icon(Icons.edit_note),
                      label: const Text('PATCH'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _working ? null : _deleteUser,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('DELETE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? Center(
                  child: TextButton.icon(
                    onPressed: _loadUsers,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Muat ulang User'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${user.id}')),
                          title: Text(user.name),
                          subtitle: Text('${user.email}\n${user.city}'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            if (user.id != userId) {
                              setState(() => _selectedUserId = user.id);
                            }
                            _showUserDetails(user);
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAdminsTab() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _adminIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Admin',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _working ? null : () => _showAdminDetails(),
                        icon: const Icon(Icons.search),
                        label: const Text('Detail'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _working ? null : _deleteAdmin,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Hapus'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _loadingAdmins
              ? const Center(child: CircularProgressIndicator())
              : _admins.isEmpty
              ? Center(
                  child: TextButton.icon(
                    onPressed: _loadAdmins,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Muat ulang Admin'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAdmins,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: _admins.length,
                    itemBuilder: (context, index) {
                      final admin = _admins[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${admin.id}')),
                          title: Text(admin.name),
                          subtitle: Text('${admin.email}\n${admin.department}'),
                          isThreeLine: true,
                          onTap: () => _showAdminDetails(admin.id),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen User & Admin'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_alt_outlined), text: 'User'),
              Tab(
                icon: Icon(Icons.admin_panel_settings_outlined),
                text: 'Admin',
              ),
            ],
          ),
        ),
        body: TabBarView(children: [_buildUsersTab(), _buildAdminsTab()]),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.name,
    required this.email,
    required this.extraLabel,
    required this.extraValue,
  });

  final String name;
  final String email;
  final String extraLabel;
  final String extraValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nama: $name'),
        const SizedBox(height: 8),
        Text('Email: $email'),
        const SizedBox(height: 8),
        Text('$extraLabel: ${extraValue.isEmpty ? '-' : extraValue}'),
      ],
    );
  }
}
