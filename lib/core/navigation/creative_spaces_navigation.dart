import 'package:flutter/material.dart';

/// Shared navigation helpers for Creative Spaces flows.
class CreativeSpacesNavigation {
  const CreativeSpacesNavigation._();

  static const String categoryRouteName = '/creative-spaces-category';
  static const String listRouteName = '/creative-spaces-list';
  static const String subCategoryRouteName = '/creative-spaces-sub-category';
  static const String detailRouteName = '/creative-space-detail';

  static Future<T?> pushCategoryPage<T extends Object?>(
    BuildContext context, {
    required WidgetBuilder pageBuilder,
    String routeName = categoryRouteName,
  }) {
    if (!context.mounted) {
      return Future.value(null);
    }

    return _push(context, routeName: routeName, pageBuilder: pageBuilder);
  }

  static Future<T?> pushSubCategoryPage<T extends Object?>(
    BuildContext context, {
    required WidgetBuilder pageBuilder,
    String routeName = subCategoryRouteName,
  }) {
    if (!context.mounted) {
      return Future.value(null);
    }

    return _push(context, routeName: routeName, pageBuilder: pageBuilder);
  }

  static Future<T?> pushDetailPage<T extends Object?>(
    BuildContext context, {
    required WidgetBuilder pageBuilder,
    String routeName = detailRouteName,
  }) {
    if (!context.mounted) {
      return Future.value(null);
    }

    return _push(context, routeName: routeName, pageBuilder: pageBuilder);
  }

  static Future<T?> pushListPage<T extends Object?>(
    BuildContext context, {
    required WidgetBuilder pageBuilder,
    String routeName = listRouteName,
  }) {
    if (!context.mounted) {
      return Future.value(null);
    }

    return _push(context, routeName: routeName, pageBuilder: pageBuilder);
  }

  static Future<T?> resetToCategoryPage<T extends Object?>(
    BuildContext context, {
    required WidgetBuilder pageBuilder,
    String routeName = categoryRouteName,
  }) {
    if (!context.mounted) {
      return Future.value(null);
    }

    return Navigator.of(context).pushAndRemoveUntil<T>(
      _buildRoute(routeName, pageBuilder),
      (route) => route.isFirst,
    );
  }

  static Future<T?> _push<T extends Object?>(
    BuildContext context, {
    required WidgetBuilder pageBuilder,
    required String routeName,
  }) {
    return Navigator.of(context).push<T>(_buildRoute(routeName, pageBuilder));
  }

  static MaterialPageRoute<T> _buildRoute<T extends Object?>(
    String routeName,
    WidgetBuilder pageBuilder,
  ) {
    return MaterialPageRoute<T>(
      builder: pageBuilder,
      settings: RouteSettings(name: routeName),
    );
  }
}
