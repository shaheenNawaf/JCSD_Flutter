import 'package:flutter/foundation.dart';

@immutable
class PayrollState {
  final List<Map<String, dynamic>> payrolls;
  final String sortBy;
  final bool ascending;
  final int currentPage;
  final int totalPages;
  final bool loading;
  final String? error;

  const PayrollState({
    required this.payrolls,
    this.sortBy = 'created_at',
    this.ascending = true,
    this.currentPage = 1,
    this.totalPages = 1,
    this.loading = false,
    this.error,
  });

  factory PayrollState.initial() {
    return const PayrollState(
      payrolls: [],
      sortBy: 'created_at',
      ascending: true,
      currentPage: 1,
      totalPages: 1,
    );
  }

  PayrollState copyWith({
    List<Map<String, dynamic>>? payrolls,
    String? sortBy,
    bool? ascending,
    int? currentPage,
    int? totalPages,
    bool? loading,
    String? error,
  }) {
    return PayrollState(
      payrolls: payrolls ?? this.payrolls,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}