import 'package:flutter/foundation.dart';
import '../../shared/models/organization.dart';
import '../../shared/services/org_service.dart';

class OrgState {
  final bool loading;
  final String? error;
  final List<Organization> items;
  final int page;
  final int limit;
  final int total;
  final String query;
  const OrgState({this.loading = false, this.error, this.items = const [], this.page = 1, this.limit = 10, this.total = 0, this.query = ''});
  OrgState copyWith({bool? loading, String? error, List<Organization>? items, int? page, int? limit, int? total, String? query}) {
    return OrgState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      query: query ?? this.query,
    );
  }
}

class OrgStore extends ChangeNotifier {
  final OrgService service;
  OrgState state = const OrgState();
  OrgStore(this.service);
  Future<void> fetch({int? page, int? limit, String? q}) async {
    state = state.copyWith(loading: true, error: null, page: page ?? state.page, limit: limit ?? state.limit, query: q ?? state.query);
    notifyListeners();
    try {
      final res = await service.list(page: state.page, limit: state.limit, q: state.query.isEmpty ? null : state.query);
      state = state.copyWith(loading: false, items: res.items, total: res.total);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
    notifyListeners();
  }
}