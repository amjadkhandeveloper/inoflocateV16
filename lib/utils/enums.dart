/// UI/async state used by providers that implement [StateInterface].
enum NotifierState {
  /// Before the first API call or after a full reset.
  initial,

  /// Request in progress — screens usually show shimmer/loader.
  loading,

  /// Request succeeded — screens render data.
  loaded,

  /// Request failed — screens show [CustomErrorWidget] or toast.
  error,
}