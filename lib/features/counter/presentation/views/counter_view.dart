import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/repositories/auth_repository.dart';
import '../viewmodels/counter_viewmodel.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key, required this.title});

  final String title;

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterViewModel _viewModel = CounterViewModel(AuthRepository());

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) => IconButton(
              icon: Icon(
                _viewModel.isLoggedIn
                    ? Icons.verified_user
                    : Icons.person_outline,
                color: _viewModel.isLoggedIn ? Colors.green : null,
              ),
              tooltip: _viewModel.isLoggedIn
                  ? 'Logged in as ${_viewModel.loggedInEmail}'
                  : 'Not logged in',
              onPressed: () => context.go('/login'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cloud),
            tooltip: 'Weather',
            onPressed: () => context.go('/weather'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => Text(
                '${_viewModel.counter}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _viewModel.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
