# Google Play Data Safety — Town Discoveries (UGC)

Use this as a reference when completing the **Data safety** section in Play Console for the TownTrek app.

## User-generated content (suggest a discovery)

- **Photos**: Optional. Submitted for moderation; not required to identify the user.
- **Optional display name**: Voluntary text (“How should we credit you?”); not used as account identity.
- **Map pin (latitude/longitude)**: User-chosen point on a map in the suggest flow; not automatic device GPS collection from the SDK for this feature.
- **Moderation**: All submissions are **pending** until approved in the TownTrek admin dashboard.
- **Report**: Discovery detail includes **Report this content** (email to support with discovery id).

## Declarations (typical)

- **Personal info**: None collected for account linking in this flow (anonymous submit).
- **Photos / videos**: Collected optionally; used for moderation and display if approved.
- **Location**: If Play Console asks about precise location, note that users may **manually** place a pin; the app does not require continuous location for suggestions.

## Mapbox

Mapbox Maps SDK: follow Mapbox’s terms; no extra Play “data safety” category is usually required unless you enable Mapbox telemetry (review current Mapbox + Play guidance).

## Backend

- Suggestions may store **submitter IP** server-side for abuse prevention (not collected via an app analytics SDK).
