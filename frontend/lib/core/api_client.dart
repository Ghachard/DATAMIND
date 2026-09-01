import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? e.message);
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? e.message);
    }
  }

  Future<List<int>> postPdf(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? e.message);
    }
  }

  Future<Map<String, dynamic>> descriptiveSimple(List<double> values, String variableName, {String dataNature = 'continuous'}) {
    return post('/api/stats/descriptive/simple', {
      'values': values,
      'variable_name': variableName,
      'data_nature': dataNature,
    });
  }

  Future<Map<String, dynamic>> descriptiveGrouped(List<double> values, List<int> frequencies, String variableName, {String dataNature = 'continuous'}) {
    return post('/api/stats/descriptive/grouped', {
      'values': values,
      'frequencies': frequencies,
      'variable_name': variableName,
      'data_nature': dataNature,
    });
  }

  Future<Map<String, dynamic>> descriptiveClasses(
      List<double> lowerBounds, List<double> upperBounds, List<int> frequencies, String variableName, {String dataNature = 'continuous'}) {
    return post('/api/stats/descriptive/classes', {
      'lower_bounds': lowerBounds,
      'upper_bounds': upperBounds,
      'frequencies': frequencies,
      'variable_name': variableName,
      'data_nature': dataNature,
    });
  }

  Future<Map<String, dynamic>> descriptiveBivariate(
      List<double> x, List<double> y, String xName, String yName, {String dataNature = 'continuous'}) {
    return post('/api/stats/descriptive/bivariate', {
      'x': x,
      'y': y,
      'x_name': xName,
      'y_name': yName,
      'data_nature': dataNature,
    });
  }

  Future<Map<String, dynamic>> computeProbability(String law, Map<String, dynamic> params,
      {double? x, double? xMin, double? xMax}) {
    final data = {'law': law, 'params': params};
    if (x != null) data['x'] = x;
    if (xMin != null) data['x_min'] = xMin;
    if (xMax != null) data['x_max'] = xMax;
    return post('/api/probability/calculate', data);
  }

  Future<Map<String, dynamic>> confidenceInterval(List<double> values, double level) {
    return post('/api/inference/confidence-interval', {
      'values': values,
      'level': level,
    });
  }

  Future<Map<String, dynamic>> oneSampleTTest(List<double> values, double referenceValue, double alpha) {
    return post('/api/inference/t-test/one-sample', {
      'values': values,
      'reference_value': referenceValue,
      'alpha': alpha,
    });
  }

  Future<Map<String, dynamic>> twoSampleTTest(List<double> sample1, List<double> sample2, double alpha) {
    return post('/api/inference/t-test/two-sample', {
      'sample1': sample1,
      'sample2': sample2,
      'alpha': alpha,
    });
  }

  Future<Map<String, dynamic>> chiSquareTest(List<double> observed, List<double> expected, double alpha) {
    return post('/api/inference/chi-square', {
      'observed': observed,
      'expected': expected,
      'alpha': alpha,
    });
  }

  Future<Map<String, dynamic>> generateChart(String chartType, {List<double>? values,
      List<int>? frequencies, List<double>? lowerBounds, List<double>? upperBounds,
      List<double>? x, List<double>? y, String? title, String? variableName}) {
    final data = <String, dynamic>{
      'chart_type': chartType,
      'data_type': values != null && frequencies == null && lowerBounds == null
          ? 'simple'
          : frequencies != null && lowerBounds == null
              ? 'grouped'
              : lowerBounds != null
                  ? 'class_interval'
                  : x != null && y != null
                      ? 'bivariate'
                      : 'simple',
      'variable_name': variableName ?? 'Variable',
    };
    if (values != null) data['values'] = values;
    if (frequencies != null) data['frequencies'] = frequencies;
    if (lowerBounds != null) data['lower_bounds'] = lowerBounds;
    if (upperBounds != null) data['upper_bounds'] = upperBounds;
    if (x != null) data['x'] = x;
    if (y != null) data['y'] = y;
    if (title != null) data['title'] = title;
    return post('/api/graphs/generate', data);
  }

  Future<Map<String, dynamic>> getChartData(String chartType, {List<double>? values,
      List<int>? frequencies, List<double>? lowerBounds, List<double>? upperBounds,
      List<double>? x, List<double>? y, String? variableName, String dataNature = 'continuous'}) {
    final data = <String, dynamic>{
      'chart_type': chartType,
      'data_type': values != null && frequencies == null && lowerBounds == null
          ? 'simple'
          : frequencies != null && lowerBounds == null
              ? 'grouped'
              : lowerBounds != null
                  ? 'class_interval'
                  : x != null && y != null
                      ? 'bivariate'
                      : 'simple',
      'variable_name': variableName ?? 'Variable',
      'data_nature': dataNature,
    };
    if (values != null) data['values'] = values;
    if (frequencies != null) data['frequencies'] = frequencies;
    if (lowerBounds != null) data['lower_bounds'] = lowerBounds;
    if (upperBounds != null) data['upper_bounds'] = upperBounds;
    if (x != null) data['x'] = x;
    if (y != null) data['y'] = y;
    return post('/api/graphs/data', data);
  }

  Future<List<int>> exportPdf(Map<String, dynamic> data) {
    return postPdf('/api/export/pdf', data);
  }

  Future<Map<String, dynamic>> getHistory() {
    return get('/api/stats/history');
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
