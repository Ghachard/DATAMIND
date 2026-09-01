import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'data_provider.dart';

class ResultState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? stats;
  final String? interpretation;
  final String? analysisId;

  ResultState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.interpretation,
    this.analysisId,
  });

  ResultState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
    String? interpretation,
    String? analysisId,
  }) {
    return ResultState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      interpretation: interpretation ?? this.interpretation,
      analysisId: analysisId ?? this.analysisId,
    );
  }

  bool get hasResult => stats != null;
}

class ResultNotifier extends StateNotifier<ResultState> {
  final ApiClient _api;

  ResultNotifier(this._api) : super(ResultState());

  Future<void> calculateSimple(List<double> values, String variableName, {String dataNature = 'continuous'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.descriptiveSimple(values, variableName, dataNature: dataNature);
      state = state.copyWith(
        isLoading: false,
        stats: result['stats'],
        interpretation: result['interpretation'],
        analysisId: result['analysis_id'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> calculateGrouped(List<double> values, List<int> frequencies, String variableName, {String dataNature = 'continuous'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.descriptiveGrouped(values, frequencies, variableName, dataNature: dataNature);
      state = state.copyWith(
        isLoading: false,
        stats: result['stats'],
        interpretation: result['interpretation'],
        analysisId: result['analysis_id'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> calculateClasses(List<double> lower, List<double> upper, List<int> frequencies, String variableName, {String dataNature = 'continuous'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.descriptiveClasses(lower, upper, frequencies, variableName, dataNature: dataNature);
      state = state.copyWith(
        isLoading: false,
        stats: result['stats'],
        interpretation: result['interpretation'],
        analysisId: result['analysis_id'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> calculateBivariate(List<double> x, List<double> y, String xName, String yName, {String dataNature = 'continuous'}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.descriptiveBivariate(x, y, xName, yName);
      state = state.copyWith(
        isLoading: false,
        stats: result['stats'],
        interpretation: result['interpretation'],
        analysisId: result['analysis_id'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() => state = ResultState();
}

final resultProvider = StateNotifierProvider<ResultNotifier, ResultState>((ref) {
  return ResultNotifier(ref.watch(apiClientProvider));
});
