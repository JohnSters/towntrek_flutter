/// Art Galleries & Studios structured detail (matches server [CreativeSpaceGalleryStudioDetailDto]).
class CreativeSpaceGalleryStudioDetailDto {
  final String? galleryType;
  final String? curatorialTheme;
  final String? featuredArtists;
  final String? exhibitionFormat;
  final bool offersStudioVisits;
  final List<String> artFormsOffered;
  final List<String> stylesAndGenres;
  final List<String> artistRepresentation;
  final List<String> priceRanges;
  final List<String> servicesOffered;
  final List<String> visitorExperience;
  final List<String> exhibitionTypes;
  final List<String> digitalPresence;

  const CreativeSpaceGalleryStudioDetailDto({
    this.galleryType,
    this.curatorialTheme,
    this.featuredArtists,
    this.exhibitionFormat,
    this.offersStudioVisits = false,
    this.artFormsOffered = const [],
    this.stylesAndGenres = const [],
    this.artistRepresentation = const [],
    this.priceRanges = const [],
    this.servicesOffered = const [],
    this.visitorExperience = const [],
    this.exhibitionTypes = const [],
    this.digitalPresence = const [],
  });

  static List<String> _stringList(dynamic v) {
    if (v is! List<dynamic>) return const [];
    return v
        .map((e) => e == null ? '' : e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  factory CreativeSpaceGalleryStudioDetailDto.fromJson(Map<String, dynamic> json) {
    return CreativeSpaceGalleryStudioDetailDto(
      galleryType: json['galleryType'] as String?,
      curatorialTheme: json['curatorialTheme'] as String?,
      featuredArtists: json['featuredArtists'] as String?,
      exhibitionFormat: json['exhibitionFormat'] as String?,
      offersStudioVisits: json['offersStudioVisits'] as bool? ?? false,
      artFormsOffered: _stringList(json['artFormsOffered']),
      stylesAndGenres: _stringList(json['stylesAndGenres']),
      artistRepresentation: _stringList(json['artistRepresentation']),
      priceRanges: _stringList(json['priceRanges']),
      servicesOffered: _stringList(json['servicesOffered']),
      visitorExperience: _stringList(json['visitorExperience']),
      exhibitionTypes: _stringList(json['exhibitionTypes']),
      digitalPresence: _stringList(json['digitalPresence']),
    );
  }

  Map<String, dynamic> toJson() => {
        'galleryType': galleryType,
        'curatorialTheme': curatorialTheme,
        'featuredArtists': featuredArtists,
        'exhibitionFormat': exhibitionFormat,
        'offersStudioVisits': offersStudioVisits,
        'artFormsOffered': artFormsOffered,
        'stylesAndGenres': stylesAndGenres,
        'artistRepresentation': artistRepresentation,
        'priceRanges': priceRanges,
        'servicesOffered': servicesOffered,
        'visitorExperience': visitorExperience,
        'exhibitionTypes': exhibitionTypes,
        'digitalPresence': digitalPresence,
      };

  bool get hasAnyVisible =>
      (galleryType != null && galleryType!.trim().isNotEmpty) ||
      (curatorialTheme != null && curatorialTheme!.trim().isNotEmpty) ||
      (featuredArtists != null && featuredArtists!.trim().isNotEmpty) ||
      (exhibitionFormat != null && exhibitionFormat!.trim().isNotEmpty) ||
      offersStudioVisits ||
      artFormsOffered.isNotEmpty ||
      stylesAndGenres.isNotEmpty ||
      artistRepresentation.isNotEmpty ||
      priceRanges.isNotEmpty ||
      servicesOffered.isNotEmpty ||
      visitorExperience.isNotEmpty ||
      exhibitionTypes.isNotEmpty ||
      digitalPresence.isNotEmpty;
}
