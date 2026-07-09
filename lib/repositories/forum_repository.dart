import '../models/forum_dto.dart';
import '../services/forum_api_service.dart';

abstract class ForumRepository {
  Future<List<ForumCategoryDto>> getCategories(int townId);
  Future<ForumTopicsResponseDto> getTopics({
    required int townId,
    int? categoryId,
    String? query,
    String filter,
    int page,
    int pageSize,
  });
  Future<ForumTopicDetailDto> getTopicDetail(
    int topicId, {
    int postsPage,
    int postsPageSize,
  });
  Future<ForumTopicDetailDto> createTopic(CreateForumTopicRequestDto request);
  Future<ForumPostDto> createPost(int topicId, CreateForumPostRequestDto request);
  Future<void> toggleReaction(int postId);
  Future<bool> toggleSubscription(int topicId);
  Future<void> reportPost(int postId, String reason);
  Future<void> reportTopic(int topicId, String reason);
}

class ForumRepositoryImpl implements ForumRepository {
  ForumRepositoryImpl(this._apiService);

  final ForumApiService _apiService;

  @override
  Future<List<ForumCategoryDto>> getCategories(int townId) =>
      _apiService.getCategories(townId);

  @override
  Future<ForumTopicsResponseDto> getTopics({
    required int townId,
    int? categoryId,
    String? query,
    String filter = 'Recent',
    int page = 1,
    int pageSize = 20,
  }) =>
      _apiService.getTopics(
        townId: townId,
        categoryId: categoryId,
        query: query,
        filter: filter,
        page: page,
        pageSize: pageSize,
      );

  @override
  Future<ForumTopicDetailDto> getTopicDetail(
    int topicId, {
    int postsPage = 1,
    int postsPageSize = 20,
  }) =>
      _apiService.getTopicDetail(
        topicId,
        postsPage: postsPage,
        postsPageSize: postsPageSize,
      );

  @override
  Future<ForumTopicDetailDto> createTopic(CreateForumTopicRequestDto request) =>
      _apiService.createTopic(request);

  @override
  Future<ForumPostDto> createPost(int topicId, CreateForumPostRequestDto request) =>
      _apiService.createPost(topicId, request);

  @override
  Future<void> toggleReaction(int postId) => _apiService.toggleReaction(postId);

  @override
  Future<bool> toggleSubscription(int topicId) =>
      _apiService.toggleSubscription(topicId);

  @override
  Future<void> reportPost(int postId, String reason) =>
      _apiService.reportPost(postId, ForumPostReportRequestDto(reason: reason));

  @override
  Future<void> reportTopic(int topicId, String reason) =>
      _apiService.reportTopic(topicId, ForumPostReportRequestDto(reason: reason));
}
