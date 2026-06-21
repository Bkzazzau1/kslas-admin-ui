import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../data/role_dashboard_api.dart';

class RoleDashboardPanel extends StatefulWidget {
  const RoleDashboardPanel({super.key});

  @override
  State<RoleDashboardPanel> createState() => _RoleDashboardPanelState();
}

class _RoleDashboardPanelState extends State<RoleDashboardPanel> {
  late final RoleDashboardApi _api;
  late Future<RoleDashboardData> _future;

  String get _role {
    final session = AuthSession.instance.session;
    if (session == null) return 'lecturer';
    if (session.primaryRole.isNotEmpty) return session.primaryRole;
    if (session.roles.isNotEmpty) return session.roles.first;
    return 'lecturer';
  }

  @override
  void initState() {
    super.initState();
    _api = RoleDashboardApi();
    _future = _api.fetchForRole(_role);
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _future = _api.fetchForRole(_role));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconForRole(_role), color: scheme.primary),
                    const SizedBox(width: 10),
                    Text('My role dashboard', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                OutlinedButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh_outlined), label: const Text('Refresh')),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<RoleDashboardData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return _RoleError(message: snapshot.error.toString(), onRetry: _reload);
                }
                final data = snapshot.data;
                if (data == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    for (final section in data.sections) ...[
                      _RoleSection(section: section),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForRole(String role) {
    switch (role) {
      case 'exam_officer':
        return Icons.assignment_turned_in_outlined;
      case 'moderator':
        return Icons.rule_folder_outlined;
      case 'hod':
        return Icons.account_tree_outlined;
      case 'dlc_director':
      case 'admin':
        return Icons.cast_for_education_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}

class _RoleSection extends StatelessWidget {
  const _RoleSection({required this.section});

  final RoleDashboardSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${section.title} (${section.items.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (section.items.isEmpty)
            Text('No live records returned yet.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
          else
            for (final item in section.items.take(6)) _RoleItemTile(item: item),
        ],
      ),
    );
  }
}

class _RoleItemTile extends StatelessWidget {
  const _RoleItemTile({required this.item});

  final RoleDashboardItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: item.subtitle.isEmpty ? null : Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Chip(label: Text(item.status), visualDensity: VisualDensity.compact),
    );
  }
}

class _RoleError extends StatelessWidget {
  const _RoleError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.errorContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role dashboard issue', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_outlined), label: const Text('Try again')),
        ],
      ),
    );
  }
}
