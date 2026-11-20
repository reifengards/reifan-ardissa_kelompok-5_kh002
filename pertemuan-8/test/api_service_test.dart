import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tugas_layout_flutter/models/admin.dart';
import 'package:tugas_layout_flutter/models/user.dart';
import 'package:tugas_layout_flutter/services/admin_service.dart';
import 'package:tugas_layout_flutter/services/api_service.dart';

void main() {
  group('model JSON parsing', () {
    test('User reads city from nested address', () {
      final user = User.fromJson({
        'id': 2,
        'name': 'User Test',
        'email': 'user@example.com',
        'address': {'city': 'Bandung'},
      });

      expect(user.city, 'Bandung');
      expect(user.toJson()['city'], 'Bandung');
    });

    test('Admin reads department from company name', () {
      final admin = Admin.fromJson({
        'id': 3,
        'name': 'Admin Test',
        'email': 'admin@example.com',
        'company': {'name': 'Engineering'},
      });

      expect(admin.department, 'Engineering');
      expect(admin.toJson()['department'], 'Engineering');
    });
  });

  test('POST always creates the practicum User ID', () async {
    late http.Request request;
    final service = ApiService(
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '{"id":101,"name":"User Praktikum","email":"user@example.com","city":"Jakarta"}',
          201,
        );
      }),
    );

    final created = await service.createUser(
      const User(
        id: 1,
        name: 'User Praktikum',
        email: 'user@example.com',
        city: 'Jakarta',
      ),
    );

    expect(request.method, 'POST');
    expect(jsonDecode(request.body)['id'], userId);
    expect(created.id, userId);
  });

  test('PUT sends the updated name and email to the selected User', () async {
    late http.Request request;
    final service = ApiService(
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '{"id":1,"name":"Ayu Updated","email":"updated@example.com"}',
          200,
        );
      }),
    );

    final updated = await service.updateUserPut(
      1,
      'Ayu Updated',
      'updated@example.com',
    );

    expect(request.method, 'PUT');
    expect(request.url.path, '/users/1');
    expect(jsonDecode(request.body), {
      'id': 1,
      'name': 'Ayu Updated',
      'email': 'updated@example.com',
    });
    expect(updated.name, 'Ayu Updated');
    expect(updated.email, 'updated@example.com');
  });

  test('PATCH appends the requested developer suffix', () async {
    late http.Request request;
    final service = ApiService(
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response('{"id":1,"name":"Ayu - Flutter Developer"}', 200);
      }),
    );

    await service.updateUserPatch(1, 'Ayu');

    expect(request.method, 'PATCH');
    expect(jsonDecode(request.body)['name'], 'Ayu - Flutter Developer');
  });

  test('getUser requests and parses the requested user ID', () async {
    late http.Request request;
    final service = ApiService(
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response(
          '{"id":7,"name":"Ayu","email":"ayu@example.com",'
          '"address":{"city":"Bandung"}}',
          200,
        );
      }),
    );

    final user = await service.getUser(7);

    expect(request.method, 'GET');
    expect(request.url.path, '/users/7');
    expect(user.city, 'Bandung');
  });

  test('Admin list includes the practicum Admin', () async {
    final service = AdminService(
      client: MockClient(
        (_) async => http.Response(
          '[{"id":1,"name":"Admin One","email":"one@example.com",'
          '"company":{"name":"Operations"}}]',
          200,
        ),
      ),
    );

    final admins = await service.getAdmins();
    final practicumAdmin = admins.firstWhere((admin) => admin.id == adminId);

    expect(practicumAdmin.department, 'Administrasi');
    expect(admins.first.department, 'Operations');
  });

  test(
    'getAdmin resolves the seeded ID when the public API returns 404',
    () async {
      final service = AdminService(
        client: MockClient((_) async => http.Response('{}', 404)),
      );

      final admin = await service.getAdmin(adminId);

      expect(admin.id, adminId);
      expect(admin.email, 'admin794@example.com');
    },
  );

  test('getAdmin does not hide a 404 for other IDs', () async {
    final service = AdminService(
      client: MockClient((_) async => http.Response('{}', 404)),
    );

    await expectLater(
      service.getAdmin(12),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('DELETE sends the requested Admin ID', () async {
    late http.Request request;
    final service = AdminService(
      client: MockClient((incoming) async {
        request = incoming;
        return http.Response('', 200);
      }),
    );

    await service.deleteAdmin(adminId);

    expect(request.method, 'DELETE');
    expect(request.url.path, '/users/$adminId');
  });
}
