# Phase 1 — Detail pages inventory (read-only)

This document consolidates the Phase 1 audit for the five listing detail entry points plus the event `widgets/` subtree. It is the repo source of truth for the refactor; do not treat the Cursor plan file as the only record.

## Entry file map

| Listing | File |
|--------|------|
| Business | `lib/screens/business_details/business_details_page.dart` |
| Service | `lib/screens/service_detail/service_detail_page.dart` |
| Event | `lib/screens/event_details/event_details_screen.dart` |
| Creative space | `lib/screens/creative_spaces/creative_space_detail_page.dart` |
| Property | `lib/screens/property_details/property_details_page.dart` |

---

## Cross-cutting (entry files + creative)

| Topic | Finding |
|-------|-----------|
| `withOpacity(` | None in audited files (use `withValues(alpha:)`). |
| File-level `Widget` functions | `creative_space_detail_page.dart`: `_gallerySurfaceCard`, `_buildErrorState`. |
| Common private builders on shell | `_detailHero` / `_eventHero` + `_buildContent` / `_buildBody` on `*Content` / `*ScreenContent` (service, business, event, property, creative). |
| `withOpacity` in event widgets/ | None. |

---

## `service_detail_page.dart`

| Column | Findings |
|--------|----------|
| Top-level `Widget` functions | None. |
| Private methods returning `Widget` | `_ServiceDetailPageContent._detailHero`, `_buildContent`. |
| `build()` > 60 lines | `_ServiceDetailBody.build` ~(lines 204–412). Shorter: `_ErrorStateView`, loading, gallery tile, page content. |
| Mutable / impure in `build` | None significant. |
| Boolean → dual layout tree | None flagged. |
| Hardcoded color | `Colors.red` on error icon. |
| Shared patterns | Loading blocks; `DetailSectionShell`; gallery row; quick actions; social wrap; service tag chips (same decoration as business). |

---

## `business_details_page.dart`

| Column | Findings |
|--------|----------|
| Top-level `Widget` functions | None. |
| Private methods returning `Widget` | `_BusinessDetailsPageContent._detailHero`, `_buildContent`. |
| `build()` > 60 lines | `_BusinessDetailsBody.build` ~145–335. |
| Mutable in `build` | None. |
| Boolean dual layout | None on flags; `_BusinessSpecialClosedHint` is data-driven. |
| Hardcoded | None beyond theme usage. |
| Shared patterns | Same as service for gallery, loading, tags, quick actions, social. |

---

## `event_details_screen.dart`

| Column | Findings |
|--------|----------|
| Top-level `Widget` functions | None. |
| Private methods returning `Widget` | `_EventDetailsScreenContent._eventHero`, `_buildBody`. |
| `build()` > 60 lines | None in this file. |
| Mutable in `build` | None. |
| Shared patterns | Composes `event_details/widgets/*`. |

---

## `property_details_page.dart`

| Column | Findings |
|--------|----------|
| Top-level `Widget` functions | None. |
| Private methods returning `Widget` | `_PropertyDetailsPageContent._detailHero`, `_buildContent` (`_listingTitle` is `String`). |
| `build()` > 60 lines | `_PropertyDetailsBody.build` ~199–380. |
| Mutable in `build` | Loop building `galleryPairs` in `build` (mutates list). |
| Hardcoded | `_FeaturedBar`: `Color(0x...)` for featured strip. |
| Shared patterns | Loading blocks; gallery tile; description gradient block. |

---

## `creative_space_detail_page.dart`

| Column | Findings |
|--------|----------|
| Top-level `Widget` functions | `_gallerySurfaceCard`, `_buildErrorState`. |
| Private methods returning `Widget` | `_CreativeSpaceDetailPageContent._detailHero`. |
| `build()` > 60 lines | `_InfoSection`, `_QuickActionsSection`, `_GalleryStudioSection` (mutable `toneCursor` + `addSurfaceCard` in `build`); long sections. |
| Boolean dual layout | `_HoursSection` (`isSpecial`); `_HourRow` (`isSpecial`); `_gallerySurfaceCard` (`compact`); `_GalleryMultiselectAccordionTile` (`uppercaseHeader` — minor). |
| Hardcoded | `_kGallerySurfaceTones` fixed hex palette; `Colors.black/amber/green/orange` in places. |
| `Hero` / motion | Gallery multiselect / grid uses tones; `Hero` on image galleries in other files. |

---

## `event_details/widgets/*` (supplement)

| File | Highlights |
|------|------------|
| `event_info_card.dart` | `_buildDetailTag`; `EventInfoCard.build` > 60 lines. |
| `event_image_gallery.dart` | `build` > 60; `[...]..sort` in `build`; `heroTag` on `TappableImage`. |
| `event_location_section.dart` | `build` > 60; `for (var i…)` in `build`. |
| `event_contact_section.dart` | `build` > 60; one default `SnackBar` without `colorScheme.error`. |
| `event_reviews_section.dart` | `_buildReviewTile`; `build` at ~60 line threshold; `Colors.amber` for stars. |

**Current event child order** (`_EventDetailsScrollContent`): `EventInfoCard` → `EventImageGallery` (if) → `EventLocationSection` → `EventContactSection` → `EventReviewsSection` (if).

---

## Phase 7 note (for sign-off)

Reordering (service/business: hours vs quick actions; creative: social vs general gallery) changes visible UX; confirm with design/product before applying.

## Phase 5(b) note

After extracting `StatelessWidget` section subtrees, spot-check `Hero` / `AnimatedSize` / similar where present.
