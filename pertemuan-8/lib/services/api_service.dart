import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

const int userId = 1501;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _usersUri = Uri.parse(
    'https://jsonplaceholder.typicode.com/users',
  );

  final http.Client _client;

  Future<List<User>> getUsers() async {
    final response = await _client.get(_usersUri);
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Respons daftar User bukan berupa list.');
    }
    return decoded
        .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<User> getUser(int id) async {
    final response = await _client.get(
      _usersUri.replace(path: '${_usersUri.path}/$id'),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Respons detail User tidak valid.');
    }
    final user = User.fromJson(Map<String, dynamic>.from(decoded));
    if (user.id == 0 || user.name.isEmpty) {
      throw const FormatException('User tidak ditemukan pada API.');
    }
    return user;
  }

  Future<User> createUser(User user) async {
    final response = await _client.post(
      _usersUri,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({...user.toJson(), 'id': userId}),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Respons pembuatan User tidak valid.');
    }
    final created = Map<String, dynamic>.from(decoded)..['id'] = userId;
    return User.fromJson(created);
  }

  Future<User> updateUserPut(int id, String name, String email) async {
    final response = await _client.put(
      _usersUri.replace(path: '${_usersUri.path}/$id'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'id': id, 'name': name, 'email': email}),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Respons pembaruan User tidak valid.');
    }
    return User.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<User> updateUserPatch(int id, String currentName) async {
    final response = await _client.patch(
      _usersUri.replace(path: '${_usersUri.path}/$id'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': '$currentName - Flutter Developer'}),
    );
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Respons PATCH User tidak valid.');
    }
    return User.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> deleteUser(int id) async {
    final response = await _client.delete(
      _usersUri.replace(path: '${_usersUri.path}/$id'),
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
