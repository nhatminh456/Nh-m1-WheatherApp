import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../../location/data/models/location_model.dart';
import '../viewmodels/home_viewmodel.dart';
import 'home_components.dart';
import 'home_shared.dart';

// Palette from the "Atmosphere" design (test.html).
const _primary = Color(0xFF00658D);
const _primaryFixed = Color(0xFFC6E7FF);
const _surface = Color(0xFFF5FAFF);
const _onSurfaceVariant = Color(0xFF3E4850);

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.viewModel, this.location});

  final HomeViewModel viewModel;
  final LocationModel? location;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load(location: widget.location);
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_primaryFixed, _surface],
          stops: [0, 0.6],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: ReiconIcon(
              icon: Reicon.outline.menu,
              color: _onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          title: Text(
            widget.location?.title ?? 'Atmosphere',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) => IconButton(
                icon: ReiconIcon(
                  icon: widget.viewModel.isLoggedIn
                      ? Reicon.filled.userTick
                      : Reicon.outline.user,
                  color: widget.viewModel.isLoggedIn
                      ? Colors.green
                      : _onSurfaceVariant,
                ),
                tooltip: widget.viewModel.isLoggedIn
                    ? 'Đã đăng nhập: ${widget.viewModel.loggedInEmail}'
                    : 'Chưa đăng nhập',
                onPressed: () => context.go('/login'),
              ),
            ),
            IconButton(
              icon: ReiconIcon(
                icon: Reicon.outline.search,
                color: _onSurfaceVariant,
              ),
              tooltip: 'Chi tiết thời tiết',
              onPressed: () {
                final defaultLocation = widget.viewModel.defaultLocation;
                if (defaultLocation != null) {
                  context.go('/weather', extra: defaultLocation);
                } else {
                  context.go('/weather');
                }
              },
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: RefreshIndicator(
              onRefresh: () => widget.viewModel.load(forceRefresh: true),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) => _buildBody(),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const HomeBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (widget.viewModel.status) {
      case HomeLoadStatus.initial:
      case HomeLoadStatus.loading:
        return const Center(child: CircularProgressIndicator(color: _primary));
      case HomeLoadStatus.error:
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Center(
              child: ReiconIcon(
                icon: Reicon.outline.cloudCross,
                size: 48,
                color: _onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.viewModel.errorMessage ?? 'Đã có lỗi xảy ra',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _primary),
                onPressed: () => widget.viewModel.load(forceRefresh: true),
                child: const Text('Thử lại'),
              ),
            ),
          ],
        );
      case HomeLoadStatus.success:
        final weather = widget.viewModel.weather!;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            HeroSection(weather: weather),
            const SizedBox(height: 32),
            BentoGrid(weather: weather),
            const SizedBox(height: 32),
            HourlyForecastCard(hourly: widget.viewModel.hourly),
            const SizedBox(height: 32),
            DailyForecastCard(daily: widget.viewModel.daily),
          ],
        );
    }
  }
}
