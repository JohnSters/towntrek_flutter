import '../../core/core.dart';
import '../../models/models.dart';

sealed class WhatToDoState {}

class WhatToDoLoading extends WhatToDoState {}

class WhatToDoError extends WhatToDoState {
  final AppError error;

  WhatToDoError(this.error);
}

class WhatToDoSection {
  final String title;
  final List<BusinessDto> businesses;

  const WhatToDoSection({required this.title, required this.businesses});
}

class WhatToDoSuccess extends WhatToDoState {
  final TownDto town;
  final List<WhatToDoSection> sections;

  WhatToDoSuccess({required this.town, required this.sections});
}
