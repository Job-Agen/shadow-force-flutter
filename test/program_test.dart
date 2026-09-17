import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_force/program_data.dart';

void main() {
  test('le programme contient 30 jours cohérents', () {
    final program = buildProgram();
    expect(program, hasLength(30));
    expect(program.first.day, 1);
    expect(program.last.day, 30);
    expect(program.every((day) => day.steps.length == 4), isTrue);
    expect(program.every((day) => day.duration >= 15 && day.duration <= 30), isTrue);
  });
}
