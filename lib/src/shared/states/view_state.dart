/// Shared state enum untuk view state management
/// Digunakan di BLoC states untuk menunjukkan status operasi
enum ViewState { initial, loading, success, error }

extension ViewStateExtension on ViewState {
  bool get isInitial => this == ViewState.initial;
  bool get isLoading => this == ViewState.loading;
  bool get isSuccess => this == ViewState.success;
  bool get isError => this == ViewState.error;
}
