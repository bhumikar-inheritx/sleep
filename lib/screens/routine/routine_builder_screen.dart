import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/colors.dart';
import '../../models/routine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/routine_provider.dart';
import '../../widgets/common/app_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/sleep_app_bar.dart';
import 'routine_execution_screen.dart';

class RoutineBuilderScreen extends StatefulWidget {
  const RoutineBuilderScreen({super.key});

  @override
  State<RoutineBuilderScreen> createState() => _RoutineBuilderScreenState();
}

class _RoutineBuilderScreenState extends State<RoutineBuilderScreen> {
  late SleepRoutine _routine;
  bool _isModified = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _routine =
        auth.profile?.windDownRoutine ??
        const SleepRoutine(id: 'new', name: 'My Ritual', steps: []);
  }

  void _saveRoutine() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.updateRoutine(_routine);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Routine saved!'),
          backgroundColor: SleepColors.primary,
        ),
      );
      setState(() => _isModified = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      backgroundImage: 'assets/images/start_ritual_background.png',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: SleepAppBar(
          title: 'Wind-Down Ritual',
          transparent: true,
          actions: [
            if (_isModified)
              TextButton(
                onPressed: _saveRoutine,
                child: const Text(
                  'Save',
                  style: TextStyle(color: SleepColors.primaryLight),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    for (int index = 0; index < _routine.steps.length; index++)
                      _buildStepCard(index, _routine.steps[index]),
                  ],
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) newIndex -= 1;
                      final steps = List<RoutineStep>.from(_routine.steps);
                      final item = steps.removeAt(oldIndex);
                      steps.insert(newIndex, item);
                      _routine = _routine.copyWith(steps: steps);
                      _isModified = true;
                    });
                  },
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, RoutineStep step) {
    return Container(
      key: ValueKey(step.id),
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.drag_handle, color: SleepColors.textMuted),
            const SizedBox(width: 16),
            _getStepIcon(step.type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${step.duration.inMinutes} minutes',
                    style: const TextStyle(
                      color: SleepColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  final steps = List<RoutineStep>.from(_routine.steps);
                  steps.removeAt(index);
                  _routine = _routine.copyWith(steps: steps);
                  _isModified = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStepIcon(RoutineStepType type) {
    IconData icon;
    Color color;
    switch (type) {
      case RoutineStepType.journal:
        icon = Icons.edit_note;
        color = Colors.blueAccent;
      case RoutineStepType.meditation:
        icon = Icons.self_improvement;
        color = Colors.tealAccent;
      case RoutineStepType.music:
        icon = Icons.music_note;
        color = Colors.purpleAccent;
      case RoutineStepType.soundscape:
        icon = Icons.water_drop;
        color = Colors.lightBlueAccent;
      case RoutineStepType.breathing:
        icon = Icons.air;
        color = Colors.greenAccent;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SleepColors.background.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddStepSheet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Start the routine
              context.read<RoutineProvider>().startRoutine(_routine);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoutineExecutionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SleepColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Start Ritual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStepSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SleepColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Add Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildAddOption(RoutineStepType.breathing, 'Breathing Exercise'),
              _buildAddOption(RoutineStepType.journal, 'Journaling'),
              _buildAddOption(RoutineStepType.meditation, 'Meditation'),
              _buildAddOption(RoutineStepType.soundscape, 'Nature Sounds'),
              _buildAddOption(RoutineStepType.music, 'Sleep Music'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption(RoutineStepType type, String label) {
    return ListTile(
      leading: _getStepIcon(type),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          final steps = List<RoutineStep>.from(_routine.steps);
          steps.add(
            RoutineStep(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: type,
              title: label,
              duration: const Duration(minutes: 5),
            ),
          );
          _routine = _routine.copyWith(steps: steps);
          _isModified = true;
        });
      },
    );
  }
}
