import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:weatherapp/main.dart';

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'OPENWEATHER_API_KEY=test-key');
    await initializeDateFormatting('vi');
  });

  testWidgets('Home dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Atmosphere'), findsOneWidget);
    expect(find.text('Dự báo'), findsOneWidget);
    expect(find.text('Vị trí'), findsOneWidget);
    expect(find.text('Cài đặt'), findsOneWidget);
  });
}
