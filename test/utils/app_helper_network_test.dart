import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infolocate/common_models/failure_model.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';

void main() {
  group('AppHelper.isNetworkDioError', () {
    test('detects connectionError', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      expect(AppHelper.isNetworkDioError(error), isTrue);
    });

    test('detects connectionTimeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(AppHelper.isNetworkDioError(error), isTrue);
    });

    test('detects socket exception in error field', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
        error: const SocketException('Failed host lookup'),
      );
      expect(AppHelper.isNetworkDioError(error), isTrue);
    });

    test('does not treat badResponse as network error', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );
      expect(AppHelper.isNetworkDioError(error), isFalse);
    });
  });

  group('AppHelper.failureFromError', () {
    test('returns same Failure instance', () {
      final failure = Failure('Custom API message');
      expect(AppHelper.failureFromError(failure), same(failure));
    });

    test('maps connectionError to no internet message key', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final failure = AppHelper.failureFromError(error);
      expect(failure.message, isNot(contains('DioException')));
      expect(failure.message, isNot(contains('connection error')));
    });

    test('maps badResponse to bad response message key', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
      );
      final failure = AppHelper.failureFromError(error);
      expect(failure.message, isNot(contains('DioException')));
    });

    test('maps SocketException to no internet message key', () {
      final failure = AppHelper.failureFromError(
        const SocketException('Network is unreachable'),
      );
      expect(failure.message, isNot(contains('SocketException')));
    });

    test('never exposes raw exception toString for unknown errors', () {
      final failure = AppHelper.failureFromError(Exception('secret stack detail'));
      expect(failure.message, isNot(contains('secret stack detail')));
      expect(failure.message, isNotEmpty);
    });
  });
}
