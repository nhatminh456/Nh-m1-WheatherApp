import 'package:flutter/material.dart';

import '../../../../shared/models/user_settings.dart';
import '../../../../shared/widgets/atmosphere_bottom_navigation_bar.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'package:go_router/go_router.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: Text(
          'Atmosphere',
          style: TextStyle(
            color: isDark ? colorScheme.primary : const Color(0xFF4A849F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = viewModel.settings;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Cài đặt hệ thống',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? colorScheme.onSurface : const Color(0xFF1A3848),
                  ),
                ),
              ),

              _buildCard(
                context: context,
                isDark: isDark,
                title: 'Đơn vị đo nhiệt độ',
                child: Column(
                  children: [
                    RadioListTile<TemperatureUnit>(
                      title: const Text('Celsius (°C)', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: TemperatureUnit.celsius,
                      groupValue: settings.temperatureUnit,
                      activeColor: isDark ? colorScheme.primary : const Color(0xFF00A2D3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        if (value != null) viewModel.updateTemperatureUnit(value);
                      },
                    ),
                    RadioListTile<TemperatureUnit>(
                      title: const Text('Fahrenheit (°F)', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: TemperatureUnit.fahrenheit,
                      groupValue: settings.temperatureUnit,
                      activeColor: isDark ? colorScheme.primary : const Color(0xFF00A2D3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        if (value != null) viewModel.updateTemperatureUnit(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildCard(
                context: context,
                isDark: isDark,
                title: 'Giao diện ứng dụng',
                child: DropdownButtonFormField<AppTheme>(
                  value: settings.appTheme,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainer : const Color(0xFFF4F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
                  items: const [
                    DropdownMenuItem(value: AppTheme.system, child: Text('Hệ thống', style: TextStyle(fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: AppTheme.light, child: Text('Sáng', style: TextStyle(fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: AppTheme.dark, child: Text('Tối', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                  onChanged: (value) {
                    if (value != null) viewModel.updateAppTheme(value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              _buildCard(
                context: context,
                isDark: isDark,
                title: 'Ngôn ngữ',
                child: DropdownButtonFormField<String>(
                  value: settings.languageCode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainer : const Color(0xFFF4F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  dropdownColor: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt', style: TextStyle(fontWeight: FontWeight.w600))),
                    DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                  onChanged: (value) {
                    if (value != null) viewModel.updateLanguage(value);
                  },
                ),
              ),
              const SizedBox(height: 16),

              _buildCard(
                context: context,
                isDark: isDark,
                title: 'Tần suất cập nhật thời tiết',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        'Cập nhật sau mỗi: ${settings.updateFrequencyMinutes} phút',
                        style: TextStyle(
                          fontWeight: FontWeight.w600, 
                          color: isDark ? colorScheme.primary : const Color(0xFF00A2D3),
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isDark ? colorScheme.primary : const Color(0xFF00A2D3),
                        inactiveTrackColor: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFE0E0E0),
                        thumbColor: isDark ? colorScheme.primary : const Color(0xFF00A2D3),
                        overlayColor: isDark ? colorScheme.primary.withValues(alpha: 0.2) : const Color(0x3300A2D3),
                        trackHeight: 4.0,
                      ),
                      child: Slider(
                        value: settings.updateFrequencyMinutes.toDouble(),
                        min: 15,
                        max: 120,
                        divisions: 7,
                        onChanged: (value) {
                          viewModel.updateFrequency(value.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await viewModel.resetToDefault();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Đã khôi phục cài đặt gốc'),
                          backgroundColor: Colors.black.withOpacity(0.8),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restore, color: Colors.redAccent),
                  label: const Text(
                    'Khôi phục cài đặt gốc',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64), // Thêm khoảng trống ở đáy
            ],
          );
        },
      ),
      bottomNavigationBar: AtmosphereBottomNavigationBar(
        selectedIndex: 4,
        onDestinationSelected: (index) {
          if (index == 0) context.go('/');
          else if (index == 2) context.go('/alerts');
          else if (index == 4) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildCard({required BuildContext context, required bool isDark, required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24), 
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_suggest_outlined, size: 20, color: isDark ? Colors.grey[400] : const Color(0xFF8E9BAE)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Theme.of(context).colorScheme.onSurface : const Color(0xFF1A3848),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
