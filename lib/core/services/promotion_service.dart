import '../models/promotion_model.dart';
import 'api_service.dart';

class PromotionService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/promotions';

  Future<List<PromotionModel>> getPromotions({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      final response = await _apiService.get(
        endpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (isActive != null) 'is_active': isActive,
        },
      );

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((item) => PromotionModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PromotionModel> getPromotionById(String id) async {
    try {
      final response = await _apiService.get('$endpoint/$id');
      return PromotionModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<PromotionModel> createPromotion(Map<String, dynamic> promotionData) async {
    try {
      final response = await _apiService.post(
        endpoint,
        data: promotionData,
      );
      return PromotionModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<PromotionModel> updatePromotion(String id, Map<String, dynamic> promotionData) async {
    try {
      final response = await _apiService.put(
        '$endpoint/$id',
        data: promotionData,
      );
      return PromotionModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await _apiService.delete('$endpoint/$id');
    } catch (e) {
      rethrow;
    }
  }
}

