import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DataInputType { simple, grouped, classes, bivariate }

enum DataNature { discrete, continuous }

class DataState {
  final DataInputType type;
  final DataNature dataNature;
  final String variableName;
  final List<double> values;
  final List<int> frequencies;
  final List<double> lowerBounds;
  final List<double> upperBounds;
  final List<double> xValues;
  final List<double> yValues;
  final String xName;
  final String yName;
  final bool isNormal;
  final double normalityPValue;

  DataState({
    this.type = DataInputType.simple,
    this.dataNature = DataNature.continuous,
    this.variableName = 'Variable',
    this.values = const [],
    this.frequencies = const [],
    this.lowerBounds = const [],
    this.upperBounds = const [],
    this.xValues = const [],
    this.yValues = const [],
    this.xName = 'X',
    this.yName = 'Y',
    this.isNormal = false,
    this.normalityPValue = 0.0,
  });

  DataState copyWith({
    DataInputType? type,
    DataNature? dataNature,
    String? variableName,
    List<double>? values,
    List<int>? frequencies,
    List<double>? lowerBounds,
    List<double>? upperBounds,
    List<double>? xValues,
    List<double>? yValues,
    String? xName,
    String? yName,
    bool? isNormal,
    double? normalityPValue,
  }) {
    return DataState(
      type: type ?? this.type,
      dataNature: dataNature ?? this.dataNature,
      variableName: variableName ?? this.variableName,
      values: values ?? this.values,
      frequencies: frequencies ?? this.frequencies,
      lowerBounds: lowerBounds ?? this.lowerBounds,
      upperBounds: upperBounds ?? this.upperBounds,
      xValues: xValues ?? this.xValues,
      yValues: yValues ?? this.yValues,
      xName: xName ?? this.xName,
      yName: yName ?? this.yName,
      isNormal: isNormal ?? this.isNormal,
      normalityPValue: normalityPValue ?? this.normalityPValue,
    );
  }

  bool get hasData {
    switch (type) {
      case DataInputType.simple:
        return values.length >= 2;
      case DataInputType.grouped:
        return values.length >= 1 && values.length == frequencies.length;
      case DataInputType.classes:
        return lowerBounds.length >= 2 &&
            lowerBounds.length == upperBounds.length &&
            lowerBounds.length == frequencies.length;
      case DataInputType.bivariate:
        return xValues.length >= 2 && xValues.length == yValues.length;
    }
  }
}

class DataNotifier extends StateNotifier<DataState> {
  DataNotifier() : super(DataState());

  void setType(DataInputType type) => state = state.copyWith(type: type);
  void setDataNature(DataNature nature) => state = state.copyWith(dataNature: nature);
  void setVariableName(String name) => state = state.copyWith(variableName: name);
  void setXName(String name) => state = state.copyWith(xName: name);
  void setYName(String name) => state = state.copyWith(yName: name);

  void setValues(List<double> values) => state = state.copyWith(values: values);
  void addValue(double value) => state = state.copyWith(values: [...state.values, value]);
  void removeValue(int index) {
    final newList = List<double>.from(state.values)..removeAt(index);
    state = state.copyWith(values: newList);
  }

  void setFrequencies(List<int> frequencies) => state = state.copyWith(frequencies: frequencies);
  void addFrequency(int freq) => state = state.copyWith(frequencies: [...state.frequencies, freq]);
  void removeFrequency(int index) {
    final newList = List<int>.from(state.frequencies)..removeAt(index);
    state = state.copyWith(frequencies: newList);
  }

  void setClassData(List<double> lower, List<double> upper, List<int> freq) {
    state = state.copyWith(lowerBounds: lower, upperBounds: upper, frequencies: freq);
  }

  void setBivariateData(List<double> x, List<double> y) {
    state = state.copyWith(xValues: x, yValues: y);
  }

  void setNormalityTest(bool isNormal, double pValue) {
    state = state.copyWith(isNormal: isNormal, normalityPValue: pValue);
  }

  void clear() => state = DataState(type: state.type);

  void parseSimpleFromText(String text) {
    final values = text
        .split(RegExp(r'[\n,;\t]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => double.tryParse(s))
        .where((d) => d != null)
        .cast<double>()
        .toList();
    state = state.copyWith(values: values);
  }

  void parseGroupedFromText(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final vals = <double>[];
    final freqs = <int>[];
    for (final line in lines) {
      final parts = line.split(RegExp(r'[\t;,]+')).map((s) => s.trim()).toList();
      if (parts.length >= 2) {
        final v = double.tryParse(parts[0]);
        final f = int.tryParse(parts[1]);
        if (v != null && f != null) {
          vals.add(v);
          freqs.add(f);
        }
      }
    }
    state = state.copyWith(values: vals, frequencies: freqs);
  }

  void parseClassFromText(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final lower = <double>[];
    final upper = <double>[];
    final freqs = <int>[];
    for (final line in lines) {
      final parts = line.split(RegExp(r'[\t;,]+')).map((s) => s.trim()).toList();
      if (parts.length >= 3) {
        final l = double.tryParse(parts[0]);
        final u = double.tryParse(parts[1]);
        final f = int.tryParse(parts[2]);
        if (l != null && u != null && f != null) {
          lower.add(l);
          upper.add(u);
          freqs.add(f);
        }
      }
    }
    state = state.copyWith(lowerBounds: lower, upperBounds: upper, frequencies: freqs);
  }

  void parseBivariateFromText(String text) {
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final x = <double>[];
    final y = <double>[];
    for (final line in lines) {
      final parts = line.split(RegExp(r'[\t;,]+')).map((s) => s.trim()).toList();
      if (parts.length >= 2) {
        final xv = double.tryParse(parts[0]);
        final yv = double.tryParse(parts[1]);
        if (xv != null && yv != null) {
          x.add(xv);
          y.add(yv);
        }
      }
    }
    state = state.copyWith(xValues: x, yValues: y);
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, DataState>((ref) {
  return DataNotifier();
});
