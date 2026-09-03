import '../utils/enums.dart';

/// User-facing error wrapper thrown by repositories and caught by providers.
///
/// Repositories map raw [DioException]/socket errors via [AppHelper.failureFromError].
/// Providers call [setFailure] to show a toast and switch UI to error state.
class Failure {
  final String? message;

  Failure(this.message);

  @override
  String toString() => message.toString();
}

/// Common contract for ChangeNotifier-based feature providers.
///
/// Implementations track [NotifierState] (loading/loaded/error) and surface
/// API failures through [setFailure] instead of leaking exception strings to UI.
mixin StateInterface {
  void setState(NotifierState state);

  void setFailure(Failure failure);
}
