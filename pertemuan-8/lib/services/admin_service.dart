import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin.dart';

const int adminId = 794;

class AdminService {
  AdminService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _adminsUri = Uri.parse(
    'https://jsonplaceholder.typicode.com/users',
  );

  static const Admin _practicumAdmin = Admin(
    id: adminId,
    name: 'Admin Praktikum',
    email: 'admin794@example.com',
    department: 'Administrasi',
  );

  final http.Client _client;

  Future<List<Admin>> getAdmins() async {
    final response = await _client.get(_adminsUri);
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Respons daftar Admin bukan berupa list.');
    }
    final admins = decoded
        .map((item) => Admin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    if (!admins.any((admin) => admin.id == adminId)) {
      admins.add(_practicumAdmin);
    }
    return admins;
  }

  Future<Admin> getAdmin(int id) async {
    final response = await _client.get(
      _adminsUri.replace(path: '${_adminsUri.path}/$id'),
    );
    if (response.statusCode == 404 && id == adminId) {
      return _practicumAdmin;
    }
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Respons detail Admin tidak valid.');
    }
    final admin = Admin.fromJson(Map<String, dynamic>.from(decoded));
    if (admin.id == id && admin.name.isNotEmpty) return admin;
    if (id == adminId) return _practicumAdmin;
    throw const FormatException('Admin tidak ditemukan pada API.');
  }

  Future<void> deleteAdmin(int id) async {
    final response = await _client.delete(
      _adminsUri.replace(path: '${_adminsUri.path}/$id'),
    );
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Permintaan API gagal (${response.statusCode}): ${response.body}',
        response.request?.url,
      );
    }
  }
}
