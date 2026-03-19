import 'package:flutter/material.dart';
import 'package:memex/utils/user_storage.dart';
import 'package:memex/db/app_database.dart';
import 'package:memex/ui/agent_activity/widgets/system_action_card.dart';
import 'package:memex/data/services/system_action_service.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:memex/ui/core/widgets/agent_logo_loading.dart';

class ActionCenterSheet extends StatelessWidget {
  const ActionCenterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppDatabase.isInitialized) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC), // matches standard app background
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        minHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.assignment_turned_in,
                        size: 20,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      UserStorage.l10n.discoveredTodoActions,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Stream Content
          Expanded(
            child: StreamBuilder<List<SystemAction>>(
              stream: (AppDatabase.instance
                      .select(AppDatabase.instance.systemActions)
                    ..where((t) => t.status
                        .equals('pending')) // Only show pending initially
                    ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
                  .watch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: AgentLogoLoading());
                }

                final actions = snapshot.data ?? [];

                if (actions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 16),
                        Text(
                          UserStorage.l10n.noPendingActions,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: actions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final action = actions[index]; // Define 'action'
                    return SystemActionCard(
                      action: action,
                      service: SystemActionService.instance,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
