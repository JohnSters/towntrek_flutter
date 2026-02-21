import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import 'town_feature_selection_state.dart';
import 'town_feature_selection_view_model.dart';
import 'widgets/widgets.dart';

class TownFeatureSelectionScreen extends StatelessWidget {
  final TownDto town;

  const TownFeatureSelectionScreen({super.key, required this.town});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TownFeatureViewModel(town),
      child: _TownFeatureSelectionScreenContent(initialTown: town),
    );
  }
}

class _TownFeatureSelectionScreenContent extends StatefulWidget {
  final TownDto initialTown;

  const _TownFeatureSelectionScreenContent({required this.initialTown});

  @override
  State<_TownFeatureSelectionScreenContent> createState() =>
      _TownFeatureSelectionScreenContentState();
}

class _TownFeatureSelectionScreenContentState
    extends State<_TownFeatureSelectionScreenContent> {
  bool _isFavourite = false;
  bool _isFavouriteActionRunning = false;

  @override
  void initState() {
    super.initState();
    _loadFavouriteState();
  }

  Future<void> _loadFavouriteState() async {
    final favouriteTown = await FavouriteTownStorage.getFavouriteTown();
    if (!mounted) return;

    setState(() {
      _isFavourite = favouriteTown?.id == widget.initialTown.id;
    });
  }

  Future<void> _toggleFavourite(TownDto town) async {
    if (_isFavouriteActionRunning) return;

    setState(() {
      _isFavouriteActionRunning = true;
    });

    if (_isFavourite) {
      await FavouriteTownStorage.clearFavouriteTown();
    } else {
      await FavouriteTownStorage.setFavouriteTown(town);
    }

    if (!mounted) return;

    setState(() {
      _isFavourite = !_isFavourite;
      _isFavouriteActionRunning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavourite
              ? '${town.name} saved as favourite'
              : '${town.name} removed from favourites',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TownFeatureViewModel>();
    final town = switch (viewModel.state) {
      TownFeatureLoaded(town: final town) => town,
    };

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: town.name,
              subtitle: town.province,
              height: TownFeatureConstants.pageHeaderHeight,
              headerType: HeaderType.default_,
              trailing: IconButton(
                onPressed: _isFavouriteActionRunning
                    ? null
                    : () => _toggleFavourite(town),
                tooltip: _isFavourite
                    ? 'Remove favourite town'
                    : 'Set as favourite town',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                ),
                icon: Icon(
                  _isFavourite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(TownFeatureConstants.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      TownFeatureConstants.pageTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: TownFeatureConstants.titleFontWeight,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: TownFeatureConstants.contentSpacing),

                    // Feature Cards
                    ..._buildFeatureCards(context, viewModel, town),
                  ],
                ),
              ),
            ),
            const BackNavigationFooter(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCards(
    BuildContext context,
    TownFeatureViewModel viewModel,
    TownDto town,
  ) {
    final features = [
      FeatureData(
        title: TownFeatureConstants.businessesTitle,
        description: TownFeatureConstants.businessesDescription,
        icon: Icons.store_mall_directory,
        color: const Color(TownFeatureConstants.businessesColor),
        onTap: () => viewModel.navigateToBusinesses(context, town),
      ),
      FeatureData(
        title: TownFeatureConstants.servicesTitle,
        description: TownFeatureConstants.servicesDescription,
        icon: Icons.handyman,
        color: const Color(TownFeatureConstants.servicesColor),
        onTap: () => viewModel.navigateToServices(context, town),
      ),
      FeatureData(
        title: TownFeatureConstants.eventsTitle,
        description: TownFeatureConstants.eventsDescription,
        icon: Icons.event,
        color: const Color(TownFeatureConstants.eventsColor),
        onTap: () => viewModel.navigateToEvents(context, town),
      ),
    ];

    return features.map((feature) {
      return Column(
        children: [
          FeatureCard(feature: feature),
          if (feature != features.last) const SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}
