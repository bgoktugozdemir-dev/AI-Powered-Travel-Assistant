import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:travel_assistant/common/services/unsplash_service.dart';
import 'package:travel_assistant/common/utils/config.dart';
import 'package:travel_assistant/common/utils/logger/logger.dart';

/// Provider for the UnsplashRepository
class UnsplashRepositoryProvider extends InheritedWidget {
  /// Creates a new [UnsplashRepositoryProvider]
  UnsplashRepositoryProvider({
    required super.child,
    super.key,
  }) : _repository = _createRepository();

  final UnsplashRepository _repository;

  /// Returns the [UnsplashRepository] instance
  UnsplashRepository get repository => _repository;

  /// Creates and configures the repository
  static UnsplashRepository _createRepository() {
    final dio = Dio();
    final service = UnsplashService(dio);
    
    return UnsplashRepository(
      service: service,
      clientId: AppConfig.unsplashApiKey,
    );
  }

  @override
  bool updateShouldNotify(UnsplashRepositoryProvider oldWidget) => false;

  /// Gets the [UnsplashRepository] from the nearest provider
  static UnsplashRepository of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<UnsplashRepositoryProvider>();
    
    if (provider == null) {
      appLogger.e('UnsplashRepositoryProvider not found in the widget tree');
      throw Exception('UnsplashRepositoryProvider not found in the widget tree');
    }
    
    return provider.repository;
  }
} 