import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../../shared/repositories/auth_repository.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.title});

  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeViewModel _viewModel = HomeViewModel(AuthRepository());

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
      bottomNavigationBar: _HomeBottomNavigationBar(),
    );
  }
}

class _HomeBottomNavigationBar extends StatelessWidget {
  const _HomeBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      // Chỉ "Dự báo" (màn hình hiện tại) có sẵn; các tab còn lại chưa có
      // màn hình tương ứng nên tạm khoá (onTap không đổi currentIndex).
      onTap: (_) {},
      backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: disabledColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      items: [
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.chartBar, disabledColor),
          activeIcon: _navIcon(Reicon.filled.chartBar, colorScheme.primary),
          label: 'Dự báo',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.location, disabledColor),
          label: 'Vị trí',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.bellAlert, disabledColor),
          label: 'Cảnh báo',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.history, disabledColor),
          label: 'Lịch sử',
        ),
        BottomNavigationBarItem(
          icon: _navIcon(Reicon.outline.settings, disabledColor),
          label: 'Cài đặt',
        ),
      ],
    );
  }

  Widget _navIcon(String path, Color color) {
    return SvgPicture.string(
      reiconSvg(path),
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
