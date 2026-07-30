import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:reicon_flutter/reicon_flutter.dart';

import '../../viewmodels/search_viewmodel.dart';

const _onSurface = Color(0xFF171C20);
const _onSurfaceVariant = Color(0xFF3E4850);
const _surfaceVariant = Color(0xFFDEE3E8);

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.viewModel,
    required this.onTapItem,
  });

  final SearchViewModel viewModel;
  final ValueChanged<String> onTapItem;

  @override
  Widget build(BuildContext context) {
    final history = viewModel.history;

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ReiconIcon(
                icon: Reicon.outline.history,
                size: 48,
                color: _onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có lịch sử tìm kiếm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tìm kiếm các thành phố để xem thông tin thời tiết.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showClearConfirmation(context),
                icon: _ReiconIcon(
                  icon: Reicon.outline.trash,
                  size: 16,
                  color: Colors.red,
                ),
                label: const Text(
                  'Xóa hết',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = history[index];
            final timeStr = _formatTimestamp(item.searchedAt);

            return _GlassPanel(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _ReiconIcon(
                      icon: Reicon.outline.history,
                      size: 20,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ),
                title: Text(
                  item.query,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                  ),
                ),
                subtitle: Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  icon: _ReiconIcon(
                    icon: Reicon.outline.trash,
                    size: 20,
                    color: _onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (item.id != null) {
                      viewModel.removeHistoryItem(item.id!);
                    }
                  },
                ),
                onTap: () => onTapItem(item.query),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat.jm().format(dateTime);

    if (itemDate == today) {
      return 'Hôm nay, $timeStr';
    } else if (itemDate == yesterday) {
      return 'Hôm qua, $timeStr';
    } else {
      return '${DateFormat('dd/MM/yyyy').format(dateTime)}, $timeStr';
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa lịch sử?'),
          content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử tìm kiếm không?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: _onSurfaceVariant)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                viewModel.clearAllHistory();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  const _ReiconIcon({required this.icon, this.size = 24, required this.color});

  final String icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      reiconSvg(icon),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
