/// Copy and quotas for the 24-hour town flyer board.
abstract final class TownFlyerConstants {
  static const String boardFallbackTitle = 'Town Adverts';
  static const String stripEmpty =
      'No live adverts yet. Post one for 24 hours.';
  static const String stripLoading = 'Loading adverts…';
  static const String stripIdleSubtitle = '24-hour posters from around town';

  static String boardTitle(String townName) {
    final name = townName.trim();
    return name.isEmpty ? boardFallbackTitle : '$name Adverts';
  }

  static String liveCountLabel(int count) {
    if (count <= 0) return stripIdleSubtitle;
    if (count == 1) return '1 live advert';
    return '$count live adverts';
  }

  static const String postAction = 'Post an advert';
  static const String composerTitle = 'Post an advert';
  static const String composerHint =
      'Shows for 24 hours. One free flyer at a time. Extra posters use your plan’s image slots.';
  static const String imageLabel = 'Poster image';
  static const String pinLabel = 'Map pin';
  static const String phoneLabel = 'Phone (optional)';
  static const String phoneHint = 'South African number for Call and WhatsApp';
  static const String pickImage = 'Choose poster';
  static const String takePhoto = 'Take photo';
  static const String pickPin = 'Drop a pin for directions';
  static const String adjustPin = 'Adjust pin';
  static const String submit = 'Post for 24 hours';
  static const String upgradeCta = 'Continue free as a Basic business account';
  static const String upgradeBody =
      'Your free 24-hour flyer is already used. Extra posters need a free Basic business account and an image slot.';
  static const String poolFullBody =
      'Extra posters use your plan’s image slots. Remove a listing photo, or wait for a flyer to expire.';
  static const String capFullBody =
      'You already have the maximum number of live flyers in this town.';
  static const String call = 'Call';
  static const String whatsapp = 'WhatsApp';
  static const String directions = 'Directions';
  static const String report = 'Report this flyer';
  static const String authTitle = 'Sign in to post';
  static const String authBody =
      'Create a free TownTrek member account on this phone to post a 24-hour flyer. Existing accounts can sign in with email, or connect a device with a TREK code.';
  static const String registerTab = 'Create account';
  static const String loginTab = 'Sign in';
  static const String fullNameLabel = 'Full name';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String termsLabel = 'I accept the TownTrek terms';
  static const String registerSubmit = 'Create account';
  static const String loginSubmit = 'Sign in';
  static const String trekFallback = 'I already have a TREK code';
  static const String reportEmail = 'admin@bytecraftdigital.com';
  static const int maxImageBytes = 5 * 1024 * 1024;
  static const double galleryViewportFraction = 0.92;
  static const double dockHeight = 72;
  static const String upgradeRequiredCode = 'UPGRADE_REQUIRED';
  static const String imagePoolFullCode = 'IMAGE_POOL_FULL';
  static const String townFlyerCapCode = 'TOWN_FLYER_CAP';
}
