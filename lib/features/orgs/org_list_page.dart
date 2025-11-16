import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/gradient_header.dart';
import '../../widgets/glass_card.dart';
import '../../shared/services/org_service.dart';
import 'org_store.dart';

class OrgListPage extends StatelessWidget {
  const OrgListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrgStore(OrgService())..fetch(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final store = context.watch<OrgStore>();
    final s = store.state;
    final pages = s.limit > 0 ? ((s.total + s.limit - 1) ~/ s.limit) : 1;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const GradientHeader(title: 'Organizations'),
        const SizedBox(height: 16),
        GlassCard(
          child: Row(children: [
            Expanded(child: TextField(controller: _search, decoration: const InputDecoration(labelText: 'Search organizations'))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: s.loading ? null : () => store.fetch(page: 1, q: _search.text.trim()), child: const Text('Search')),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: s.loading
              ? const Center(child: CircularProgressIndicator())
              : s.error != null
                  ? Center(child: Text(s.error!, style: const TextStyle(color: Colors.red)))
                  : ListView.separated(
                      itemCount: s.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final org = s.items[i];
                        return GlassCard(
                          child: Row(children: [
                            const Icon(Icons.business, color: Colors.white70),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(org.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                                Text(org.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                              ]),
                            ),
                            Text(org.shortName ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                          ]),
                        );
                      },
                    ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Page ${s.page} of $pages'),
          Row(children: [
            TextButton(onPressed: s.loading || s.page <= 1 ? null : () => store.fetch(page: s.page - 1), child: const Text('Prev')),
            const SizedBox(width: 8),
            TextButton(onPressed: s.loading || s.page >= pages ? null : () => store.fetch(page: s.page + 1), child: const Text('Next')),
          ]),
        ]),
      ]),
    );
  }
}