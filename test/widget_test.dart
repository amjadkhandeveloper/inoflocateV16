import 'package:flutter_test/flutter_test.dart';
import 'package:infolocate/screens/dashboard/view/sequel_dashboard_view.dart';
import 'package:infolocate/utils/app_routes.dart';

/// The stock counter smoke test does not match this app.
/// Feature coverage lives in `test/features/`.
void main() {
  test('logged-in users open the shared dashboard route', () {
    expect(AppRoutes.dashboardRoute(), SequelDashboardScreen.routeName);
  });
}
