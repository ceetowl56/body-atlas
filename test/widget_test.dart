import 'package:flutter_test/flutter_test.dart';

import 'package:body_atlas/ads/ad_service.dart';
import 'package:body_atlas/app.dart';

void main() {
  testWidgets('App shows bottom navigation tabs', (tester) async {
    AdService.enabled = false;
    await tester.pumpWidget(const BodyAtlasApp());
    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Quiz'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
  });
}
