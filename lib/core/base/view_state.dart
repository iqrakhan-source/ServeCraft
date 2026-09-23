enum ViewStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class ViewState<T> {
  final ViewStatus status;
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  const ViewState._({
    required this.status,
    this.data,
    this.errorMessage,
    this.statusCode,
  });

  factory ViewState.initial() => const ViewState._(status: ViewStatus.initial);

  factory ViewState.loading() => const ViewState._(status: ViewStatus.loading);

  factory ViewState.success(T data) => ViewState._(
        status: ViewStatus.success,
        data: data,
      );

  factory ViewState.empty() => const ViewState._(status: ViewStatus.empty);

  factory ViewState.error(String message, {int? statusCode}) => ViewState._(
        status: ViewStatus.error,
        errorMessage: message,
        statusCode: statusCode,
      );

  bool get isInitial => status == ViewStatus.initial;
  bool get isLoading => status == ViewStatus.loading;
  bool get isSuccess => status == ViewStatus.success;
  bool get isEmpty => status == ViewStatus.empty;
  bool get isError => status == ViewStatus.error;
}
