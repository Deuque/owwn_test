import 'package:http/http.dart';

class ResponseModel<T> {
  final T? value;
  final Object? error;

  ResponseModel({this.value, this.error})
      : assert(value != null || error != null);
}

Future<ResponseModel<T>> makeRequest<T>({
  required Future<Response> Function() call,
  required ResponseModel<T> Function(String, int) onError,
  required ResponseModel<T> Function(Response) onSuccess,
  required int successCode,
}) async {
  try {
    final response = await call();
    if (response.statusCode == successCode) {
      return onSuccess(response);
    } else {
      return onError(response.body, response.statusCode);
    }
  } catch (e) {
    return onError(e.toString(), 404);
  }
}
