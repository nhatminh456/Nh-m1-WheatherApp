import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../viewmodels/search_viewmodel.dart';
import 'widgets/favorites_view.dart';
import 'widgets/history_view.dart';

const _primary = Color(0xFF00658D);
const _primaryFixed = Color(0xFFC6E7FF);
const _surface = Color(0xFFF5FAFF);
const _onSurface = Color(0xFF171C20);
const _onSurfaceVariant = Color(0xFF3E4850);
const _surfaceVariant = Color(0xFFDEE3E8);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          leading: IconButton(
            icon: _ReiconIcon(
              icon: Reicon.outline.arrowLeft,
              color: _onSurface,
            ),
            onPressed: () => context.go('/'),
          ),
          title: const Text(
            'Tìm kiếm địa điểm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _primary,
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
                        style: const TextStyle(color: _onSurface),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên thành phố (ví dụ: Hà Nội)...',
                          hintStyle: TextStyle(
                            color: _onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          icon: _ReiconIcon(
                            icon: Reicon.outline.search,
                            color: _onSurfaceVariant,
                          ),
                          suffixIcon: widget.viewModel.status == SearchStatus.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _primary,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  icon: _ReiconIcon(
                                    icon: Reicon.outline.arrowRight,
                                    color: _primary,
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
                        color: _surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: _primary,
                        unselectedLabelColor: _onSurfaceVariant,
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
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
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
