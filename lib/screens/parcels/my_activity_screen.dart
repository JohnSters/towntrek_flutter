import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import 'parcel_ui.dart';
import 'request_detail_screen.dart';

class MyActivityViewModel extends ChangeNotifier {
  MyActivityViewModel({required MemberRepository repository})
    : _repository = repository {
    load();
  }

  final MemberRepository _repository;

  bool loading = true;
  String? error;
  MemberActivityDto? activity;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      activity = await _repository.getMyActivity();
    } catch (err) {
      error = err.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

class MyActivityScreen extends StatelessWidget {
  const MyActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyActivityViewModel(
        repository: serviceLocator.memberRepository,
      ),
      child: const _MyActivityBody(),
    );
  }
}

class _MyActivityBody extends StatelessWidget {
  const _MyActivityBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyActivityViewModel>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Activity'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Requests'),
              Tab(text: 'My Deliveries'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            if (viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.error != null || viewModel.activity == null) {
              return Center(
                child: Text(viewModel.error ?? 'Unable to load activity'),
              );
            }
            return TabBarView(
              children: [
                _ParcelListView(items: viewModel.activity!.myRequests),
                _ParcelListView(items: viewModel.activity!.myDeliveries),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ParcelListView extends StatelessWidget {
  const _ParcelListView({required this.items});

  final List<ParcelSummaryDto> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Nothing here yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final parcel = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ParcelCard(
            parcel: parcel,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RequestDetailScreen(requestId: parcel.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
