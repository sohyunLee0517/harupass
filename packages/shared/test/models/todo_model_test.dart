import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('TodoModel', () {
    test('fromJson creates correct model', () {
      final json = {
        'id': 'todo1',
        'title': '수학 문제풀기',
        'description': '수학 교과서 30~35페이지',
        'status': 'pending',
        'createdBy': 'admin',
      };

      final todo = TodoModel.fromJson(json);

      expect(todo.id, 'todo1');
      expect(todo.title, '수학 문제풀기');
      expect(todo.description, '수학 교과서 30~35페이지');
      expect(todo.status, TodoStatus.pending);
      expect(todo.createdBy, TodoCreator.admin);
      expect(todo.isCompleted, false);
    });

    test('isCompleted returns true only when approved', () {
      final pending = TodoModel.fromJson({
        'id': '1',
        'title': 't',
        'status': 'pending',
      });
      final submitted = TodoModel.fromJson({
        'id': '2',
        'title': 't',
        'status': 'submitted',
      });
      final approved = TodoModel.fromJson({
        'id': '3',
        'title': 't',
        'status': 'approved',
      });
      final rejected = TodoModel.fromJson({
        'id': '4',
        'title': 't',
        'status': 'rejected',
      });

      expect(pending.isCompleted, false);
      expect(submitted.isCompleted, false);
      expect(approved.isCompleted, true);
      expect(rejected.isCompleted, false);
    });

    test('toJson roundtrip preserves data', () {
      final todo = TodoModel(
        id: 'todo1',
        title: '독서하기',
        status: TodoStatus.submitted,
        photoUrl: 'http://example.com/photo.jpg',
        submittedAt: DateTime(2026, 5, 1, 10, 30),
        createdBy: TodoCreator.subject,
      );

      final json = todo.toJson();
      final restored = TodoModel.fromJson(json);

      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.status, todo.status);
      expect(restored.photoUrl, todo.photoUrl);
      expect(restored.createdBy, TodoCreator.subject);
    });

    test('fromJson defaults status to pending', () {
      final json = {'id': '1', 'title': 'test'};
      final todo = TodoModel.fromJson(json);

      expect(todo.status, TodoStatus.pending);
      expect(todo.createdBy, TodoCreator.admin);
    });
  });
}
