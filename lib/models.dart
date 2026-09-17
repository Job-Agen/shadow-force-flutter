enum Pose { guard, jab, cross, hook, slip, footwork, strength, breathe }

class ExerciseStep {
  const ExerciseStep({
    required this.title,
    required this.subtitle,
    required this.seconds,
    required this.pose,
    required this.instructions,
    required this.mistake,
  });

  final String title;
  final String subtitle;
  final int seconds;
  final Pose pose;
  final List<String> instructions;
  final String mistake;
}

class TrainingDay {
  const TrainingDay({
    required this.day,
    required this.title,
    required this.focus,
    required this.phase,
    required this.duration,
    required this.recovery,
    required this.steps,
  });

  final int day;
  final String title;
  final String focus;
  final String phase;
  final int duration;
  final bool recovery;
  final List<ExerciseStep> steps;
}
