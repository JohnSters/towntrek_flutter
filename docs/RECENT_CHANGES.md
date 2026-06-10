# TownTrek Flutter — Recent Changes & Features

**Generated:** 10 June 2026  
**Repository:** `towntrek_flutter`  
**Branch:** `main` (up to date with `origin/main`)  
**App version (committed):** `1.1.2+19`

This document summarizes features, enhancements, and refactors added over the past ~12 weeks (late March through late May 2026), based on git commit history and the current working tree.

---

## Git Status Snapshot

At the time this document was written, the working tree had **significant uncommitted changes** — not yet on `main`:

| Category | Count |
|----------|------:|
| Modified files | 119 |
| Deleted files (moved/refactored) | ~30 |
| New untracked files/directories | ~25 |

**High-level picture:** A large architectural cleanup is in progress on top of the committed work below — consolidating networking, JSON parsing, widget organization, and DTO structure. See [Work In Progress (Uncommitted)](#work-in-progress-uncommitted) for details.

---

## Summary of Major Feature Areas

| Area | Status | Highlights |
|------|--------|------------|
| **Discovery & Map** | Shipped | Mapbox integration, voting, suggestions, detail pages, map picker |
| **Member Hub (Parcels)** | Shipped | Mobile auth, XP/progression, leaderboard, board, device connect |
| **Town Hub** | Shipped | Town admin profile, notice board, weather on pulse card |
| **Events** | Shipped | Recurring events, market stalls, collapsible descriptions, improved DTOs |
| **Businesses & Services** | Shipped | Open/closed status, operating hours, equipment rental, business card |
| **Creative Spaces** | Shipped | Gallery studio details, multiselect UI, accordion on narrow screens |
| **Properties** | Shipped | Property listings and detail screens |
| **Theming & UX** | Shipped | Dark mode, ThemeExtensions, collapsible text, error feedback |
| **Session & Auth** | Shipped + WIP | Device disconnect, multi-account sessions, QR scanner dep, JWT utils |
| **Architecture** | WIP | ApiEndpoints, JsonHelpers, interceptors, widget folder reorg |

---

## Shipped Features (Committed to `main`)

### March 28–29, 2026 — Foundation & Listings

- **Properties & equipment rentals** — New property listing cards and detail screens; equipment rental information on business detail pages.
- **Town feature selection refactor** — Updated constants and UI for the town hub entry point.
- **Business card overhaul** — Refactored hero header, widget structure, and search functionality.
- **Creative spaces UI** — Updated cards, constants, and listing presentation.
- **Event & service detail polish** — Refactored detail UI components; fixes to mobile screens and event details.
- **Entity listing theme** — Centralized listing theme via `ThemeExtension`; shared hero headers, search bars, info chips, and results bands.
- **Open/closed status** — `EntityOpenClosedBanner` and status indicators on listing cards and detail pages for businesses and services.
- **Operating hours** — Shared hours logic and UI for businesses and services; 12-hour AM/PM formatting.
- **Quick action buttons** — New detail-page quick actions (call, directions, web, etc.).
- **Rating display** — Consistent rating logic across business and creative space widgets.
- **API logging** — HTTP logging with header redaction for sensitive values.

### March 31 – April 2, 2026 — Discovery Module

- **Mapbox SDK integration** — Map-based discovery browsing and location picking.
- **Discovery feature set** — Categories, featured discoveries, list/detail views, and vote rail.
- **Discovery voting** — Up/down voting with API integration and UI feedback.
- **Suggest Discovery** — User-submitted discovery suggestions with images, location, and metadata.
- **What To Do screen** — Enhanced layout tying into discovery content.
- **Discovery detail enhancements** — Seasonal notes, image handling, and formatter utilities.
- **Landing page banners** — Info and issue banner messages on the landing page.
- **Town DTO extensions** — Additional town properties for discovery and hub features.

### April 7–8, 2026 — Theming & Member Hub Launch

- **Dark mode** — Full dark theme support via `ThemeExtension`-based design tokens.
- **Parcel Board & mobile authentication** — Access-code sign-in, device linking, and the member hub shell.
- **Member hub screens:**
  - Access code entry
  - Parcel board (member and guest views)
  - Profile & progress screens
  - Leaderboard
  - My activity
  - Post request / request detail
  - Connect device sheet
  - XP feedback UI and level badges

### April 9–13, 2026 — Member Hub Iteration

- **Parcel theming & UI** — Consistent member-hub visual language and tier styling.
- **Member progression** — XP, levels, and progression DTOs wired to API.
- **Level badge component** — Enhanced badge display on profile and related screens.
- **Connect device flow** — Improved device pairing UX.
- **Parcel board refactor** — Board layout and town hub member sheet integration.
- **Route listing perspective** — Parcel board supports route-listing context.
- **Error handling refactor** — Centralized error feedback and user-facing error views.

### April 20–23, 2026 — UX Polish & Creative Spaces

- **Business card footer labels** — Dynamic back-navigation labels based on category context (v1.1.1+18).
- **Device disconnect** — Users can disconnect their device from profile; server-side session revocation; sign-out before redeeming a new access code.
- **Collapsible descriptions** — `CollapsibleDetailTextBlock` and `CollapsibleGradientDescriptionCard` on business, creative space, event, property, and service detail screens.
- **View count simplification** — Streamlined view-count display on event and property detail screens.
- **Gallery studio details (v1.1.2+19)** — New `galleryStudio` field on creative space models; dedicated gallery studio section on detail screen.
- **Gallery multiselect UI** — Surface-tone cards and chips for art forms/styles.
- **Accordion layout** — Multiselect accordion tile for narrow screens on creative space detail.

### April 28 – May 29, 2026 — Events, Business, Town Hub & Session

- **Dependency updates** — `font_awesome_flutter` updated; `mapbox_maps_flutter` pinned for compatibility.
- **Business & event detail refactor** — New hero and state-body widget decomposition.
- **Equipment rental & documents** — Clearer hire-rate labeling (“from” rates), business documents section, improved empty-state messaging.
- **Event DTO refactor** — Dual camelCase/PascalCase JSON parsing; `townName` field; nullable image/review handling; `returnedCount` on paginated responses; town-based event filtering.
- **Recurring events & market stalls** — `isRecurring`, `nextOccurrenceDate`, and `typeDetails` surfaced on event cards and detail screens.
- **Town admin & notices** — Town admin profile banner and published notice board on town feature selection screen; new DTOs and API URL builders.
- **Member hub rename** — `parcels` screens renamed to `member_hub`; all `*Page` screens renamed to `*Screen` for naming consistency; unused files removed.
- **Session management enhancements:**
  - `TownTrekApp` converted to `StatefulWidget` for lifecycle-aware session refresh on resume.
  - Multi-linked-account support in `MobileSessionManager`.
  - Automatic session refresh on 401 responses.
  - `mobile_scanner` dependency added for QR code scanning.
  - Additional linter rules in `analysis_options.yaml`.

---

## Work In Progress (Uncommitted)

The following changes exist locally but are **not yet committed**. They represent the next wave of cleanup and feature hardening.

### Architecture & Networking

- **`ApiEndpoints`** — Extracted REST path builders from the monolithic `ApiConfig`.
- **`ApiClient` slim-down** — Core HTTP client reduced; logic moved to dedicated modules.
- **`api_interceptors.dart`** — Auth refresh, error handling, retry, and structured HTTP logging interceptors.
- **`api_error_parsers.dart` / `api_exception.dart`** — Typed API error parsing and exception types.
- **`JsonHelpers`** — Shared dual-cased JSON coercion utilities used across DTOs (replacing per-model private parsers).
- **`jwt_utils.dart`** — JWT subject decoding for per-account local session keys.
- **Repository layer expansion** — New `DiscoveryRepository`; repositories refactored to use slimmer API services.

### Models & Presentation Layer

- **DTO consolidation** — Event, parcel, member progression, and mobile auth DTOs simplified; parsing delegated to `JsonHelpers`.
- **`EventDisplay` extension** — Presentation logic (dates, prices, recurring display) moved out of `EventDto` into `core/presentation/event_display.dart`.
- **New member models** — `member_achievement_dto.dart`, `member_leaderboard_dto.dart`, `member_xp_dto.dart`, `parcel_request_dto.dart`, `parcel_summary_dto.dart`.
- **`what_to_do_copy.dart`** — Extracted copy/strings for the What To Do screen.

### Widget Organization

Widgets reorganized from flat `core/widgets/` into focused subfolders:

| Folder | Contents |
|--------|----------|
| `core/widgets/listing/` | Hero header, search bar, info chips, results band, back footer, live events strip, wrong-town strip |
| `core/widgets/feedback/` | Error view, error feedback, scaffold messenger |
| `core/widgets/discovery/` | Map widget, vote rail |
| `core/widgets/detail/` | Existing detail widgets (hours grid, collapsible text, banners, etc.) |
| `core/widgets/widgets.dart` | Barrel export |

- **`discovery/map_picker_screen.dart`** — Discovery map picker moved from `core/widgets/` into `screens/discovery/`.
- **`detail_hours_mappers.dart`** — Moved from widgets to `core/utils/`.
- **`weather_icon.dart`** — WMO weather code → Material icon mapping for town pulse card.
- **`connected_header_button_style.dart`** — Shared connected-header button styling.
- **Removed duplicate error/status widgets** — Service list and service detail screen-local error views and status indicators deleted in favor of shared components.

### Theming

- **`listing_gradients.dart`** — Listing gradient tokens extracted from inline theme code.
- **`listing_status_colors.dart`** — Open/closed and status color tokens.
- **Removed `entity_listing_theme.dart`** — Superseded by theme extensions and listing-specific modules.
- **`app_layout.dart`** — Shared layout constants.

### Screens & Services Touched

Nearly all listing and detail flows were updated to use the new imports and slimmer services:

- Business card, category, and details
- Creative spaces (list, category, detail)
- Current events and event details
- Discovery detail and suggest discovery
- Landing page, property list/details
- Service list, category, and detail
- Town feature selection and What To Do
- Member hub (connect device, XP feedback)
- Weather service refactor

### Tests

- `discovery_vote_rail_test.dart` — Updated import paths for relocated vote rail widget.

---

## Version History (Recent)

| Version | Date | Notes |
|---------|------|-------|
| 1.1.2+19 | Apr 23, 2026 | Gallery studio details; creative space multiselect UI |
| 1.1.1+18 | Apr 20, 2026 | Business card footer label improvements |

---

## Commit Reference (Chronological)

<details>
<summary>All 51 commits since March 28, 2026 (click to expand)</summary>

| Date | Commit | Summary |
|------|--------|---------|
| 2026-03-28 | `99b30b6` | Refactor Town Feature Constants and UI Components |
| 2026-03-28 | `74f3192` | Add properties and equipment rentals features |
| 2026-03-29 | `f38a868` | Enhance property and business detail features |
| 2026-03-29 | `e48c57a` | Fixes to mobile screens and event details page |
| 2026-03-29 | `ce0b439` | Refactor Event Details Screen and UI Components |
| 2026-03-29 | `30afbff` | Update Creative Spaces UI and Constants |
| 2026-03-29 | `813f212` | Refactor Business Card UI Components |
| 2026-03-29 | `6fd34ae` | Enhance Business Card and Creative Spaces UI Components |
| 2026-03-29 | `27bffb8` | Refactor Event and Service Detail UI Components |
| 2026-03-29 | `770fc16` | Refactor Entity Listing Theme and UI Components |
| 2026-03-29 | `839ec99` | Enhance EntityOpenClosedBanner and Business Detail Integration |
| 2026-03-29 | `5769a42` | Add new quick action buttons and refine UI components |
| 2026-03-29 | `042da4f` | Enhance Business Card and Search Functionality |
| 2026-03-30 | `06d3abf` | Enhance Creative Spaces and Entity Listing UI Components |
| 2026-03-30 | `afa6827` | Add Open/Closed Status Feature to Listing Cards |
| 2026-03-30 | `6c1d51a` | Refactor Business and Service Operating Hours Logic |
| 2026-03-30 | `fabc3e2` | Enhance Business Operating Hours Logic and UI Components |
| 2026-03-30 | `13fb01d` | Enhance API Logging and Header Redaction |
| 2026-03-30 | `7f106f1` | Refactor Rating Display Logic in Business and Creative Space Widgets |
| 2026-03-31 | `9cf8f12` | Add Mapbox SDK and Discovery Features |
| 2026-03-31 | `f74206e` | Update version and adjust local network URL in API configuration |
| 2026-03-31 | `84fafc8` | Enhance Discovery Map Widget and Detail Pages |
| 2026-03-31 | `9ba7f99` | Update version and enhance voting functionality in discovery features |
| 2026-03-31 | `1d17bd3` | Add new constants and enhance Suggest Discovery screen layout |
| 2026-03-31 | `939fc5c` | Enhance Discovery Detail and What To Do Screens with New UI Components |
| 2026-04-02 | `4c2a9a6` | Refactor Discovery Detail Page to Enhance Seasonal Notes and Image Handling |
| 2026-04-02 | `d9233d0` | Add info and issue banner messages to Landing Page |
| 2026-04-07 | `a51c6ed` | Update discovery constants and enhance town DTO with new properties |
| 2026-04-08 | `68a2391` | Implement Dark Mode and Refactor Theme System with ThemeExtensions |
| 2026-04-08 | `4c559b9` | Implement Parcel Board feature and mobile authentication system |
| 2026-04-09 | `308fade` | Enhance Parcel Screens with Theming and UI Improvements |
| 2026-04-09 | `a072764` | Enhance Member Progression and Parcel Features |
| 2026-04-09 | `5cae4d2` | Enhance LevelBadge Component and Profile Screens |
| 2026-04-09 | `081bd57` | Update Parcel Features and Connect Device Flow |
| 2026-04-10 | `60f28e3` | Refactor Parcel Board and Town Hub Member Features |
| 2026-04-13 | `c097d24` | Enhance Parcel Features with Route Listing Perspective |
| 2026-04-13 | `bbbb0f5` | Refactor Error Handling and Enhance User Feedback |
| 2026-04-20 | `6ee3032` | Update version and enhance business card footer label functionality |
| 2026-04-21 | `7e986df` | Implement Device Disconnect Functionality and Session Management Enhancements |
| 2026-04-21 | `75a5761` | Refactor Description Handling and Introduce Collapsible Detail Widgets |
| 2026-04-22 | `d5e04d9` | Refactor Event and Property Details Screens to Simplify View Count Logic |
| 2026-04-23 | `7966504` | Update version to 1.1.2+19 and add gallery studio details to creative space models |
| 2026-04-23 | `7adb36d` | Add gallery surface tones and multiselect card widget to creative space detail page |
| 2026-04-23 | `b726743` | Add multiselect accordion layout for narrow screens in creative space detail page |
| 2026-04-28 | `893dff5` | Update dependencies and refactor business and event detail screens |
| 2026-05-14 | `58b3ed4` | Enhance business detail display and equipment rental information |
| 2026-05-20 | `e3b66d8` | Refactor Event DTOs and Enhance JSON Parsing Logic |
| 2026-05-21 | `4e81434` | Expose recurring events and market stall details in the mobile app |
| 2026-05-28 | `c3532c1` | Add Town Admin and Notices Features to Town Feature Selection |
| 2026-05-29 | `49cd95a` | Fixed naming conventions; member hub screen renames |
| 2026-05-29 | `ad8c46c` | Enhance app configuration and session management |

</details>

---

## Suggested Next Steps

1. **Commit the in-progress refactor** — The uncommitted work is substantial (~5,200 lines removed, ~680 added) and should be reviewed, tested, and committed as one or more focused PRs.
2. **Update `CHANGELOG.md`** — Merge the shipped entries from this document into the project changelog.
3. **Run the full test suite** — Especially `discovery_vote_rail_test.dart` and any integration tests after the widget/network moves.
