import '../core/network/api_client.dart';
import '../models/forum_dto.dart';

class ForumApiService {
  ForumApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ForumCategoryDto>> getCategories(int townId) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/api/forum/categories',
      queryParameters: {'townId': townId},
    );
    return (response.data ?? const [])
        .map((item) => ForumCategoryDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ForumTopicsResponseDto> getTopics({
    required int townId,
    int? categoryId,
    String? query,
    String filter = 'Recent',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/forum/topics',
      queryParameters: {
        'townId': townId,
        'categoryId': ?categoryId,
        if (query != null && query.isNotEmpty) 'query': query,
        'filter': filter,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return ForumTopicsResponseDto.fromJson(response.data!);
  }

  Future<ForumTopicDetailDto> getTopicDetail(
    int topicId, {
    int postsPage = 1,
    int postsPageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/api/forum/topics/$topicId',
      queryParameters: {
        'postsPage': postsPage,
        'postsPageSize': postsPageSize,
      },
    );
    return ForumTopicDetailDto.fromJson(response.data!);
  }

  Future<ForumTopicDetailDto> createTopic(CreateForumTopicRequestDto request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/forum/topics',
      data: request.toJson(),
    );
    return ForumTopicDetailDto.fromJson(response.data!);
  }

  Future<ForumPostDto> createPost(int topicId, CreateForumPostRequestDto request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/forum/topics/$topicId/posts',
      data: request.toJson(),
    );
    return ForumPostDto.fromJson(response.data!);
  }

  Future<void> toggleReaction(int postId, {String type = 'Like'}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/forum/posts/$postId/reactions',
      data: {'type': type},
    );
  }

  Future<bool> toggleSubscription(int topicId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/api/forum/topics/$topicId/subscription',
    );
    return response.data?['isSubscribed'] as bool? ?? false;
  }

  Future<void> reportPost(int postId, ForumPostReportRequestDto request) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/forum/posts/$postId/report',
      data: request.toJson(),
    );
  }

  Future<void> reportTopic(int topicId, ForumPostReportRequestDto request) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/api/forum/topics/$topicId/report',
      data: request.toJson(),
    );
  }
}
