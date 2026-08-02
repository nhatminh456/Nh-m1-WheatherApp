import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../viewmodels/search_viewmodel.dart';
import 'widgets/favorites_view.dart';
import 'widgets/history_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.viewModel});

  final SearchViewModel viewModel;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onSearchSubmit(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thành phố!')),
      );
      return;
    }

    final result = await widget.viewModel.searchLocation(trimmed);
    if (result != null && mounted) {
      _searchController.clear();
      final lat = result['latitude'];
      final lon = result['longitude'];
      final name = result['name'] as String;

      // Chuyển hướng sang WeatherView chi tiết với tọa độ của thành phố tìm thấy
      context.go(
        '/weather?lat=$lat&lon=$lon&name=${Uri.encodeComponent(name)}',
      );
    } else if (widget.viewModel.errorMessage != null && mounted) {
      final errorColor = Theme.of(context).colorScheme.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage!),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final primaryFixed = colorScheme.primaryContainer;
    final surface = colorScheme.surface;
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final surfaceVariant = colorScheme.surfaceContainerHighest;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryFixed, surface],
          stops: const [0, 0.6],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: _ReiconIcon(
              icon: Reicon.outline.arrowLeft,
              color: onSurface,
            ),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            'Tìm kiếm địa điểm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return Column(
                children: [
                  // Thanh Tìm kiếm (Search Bar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: onSurface),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên thành phố (ví dụ: Hà Nội)...',
                          hintStyle: TextStyle(
                            color: onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          icon: _ReiconIcon(
                            icon: Reicon.outline.search,
                            color: onSurfaceVariant,
                          ),
                          suffixIcon: widget.viewModel.status == SearchStatus.loading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primary,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: _ReiconIcon(
                                    icon: Reicon.outline.arrowRight,
                                    color: primary,
                                  ),
                                  onPressed: () => _onSearchSubmit(_searchController.text),
                                ),
                        ),
                        onSubmitted: _onSearchSubmit,
                      ),
                    ),
                  ),

                  // Tab Bar điều hướng giữa Lịch sử và Yêu thích
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: primary,
                        unselectedLabelColor: onSurfaceVariant,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Lịch sử tìm kiếm'),
                          Tab(text: 'Yêu thích'),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content (Nội dung các Tab)
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab Lịch sử tìm kiếm
                        RefreshIndicator(
                          onRefresh: widget.viewModel.load,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              HistoryView(
                                viewModel: widget.viewModel,
                                onTapItem: _onSearchSubmit,
                              ),
                            ],
                          ),
                        ),

                        // Tab Yêu thích
                        RefreshIndicator(
                          onRefresh: widget.viewModel.load,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              FavoritesView(
                                viewModel: widget.viewModel,
                                onTapItem: (name, lat, lon) {
                                  context.go(
                                    '/weather?lat=$lat&lon=$lon&name=${Uri.encodeComponent(name)}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReiconIcon extends StatelessWidget {
  const _ReiconIcon({required this.icon, required this.color});

  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      reiconSvg(icon),
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
