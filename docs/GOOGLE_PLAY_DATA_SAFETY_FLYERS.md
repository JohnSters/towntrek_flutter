# Google Play Data Safety — Town Flyers

Use this as a reference when completing the **Data safety** section in Play Console for the TownTrek app’s 24-hour town flyer board.

## Account

- **Email and name**: Collected when a user creates a Member account in the app to post a flyer (email/password). Existing accounts can also sign in with the same details, or connect a device with a TREK code.
- **Optional phone**: Entered by the user so neighbours can Call or WhatsApp from the flyer. Not required.
- **Account deactivation**: In-app **Deactivate account** on Profile sets the account inactive, hides live flyers, and signs this device out. Required for Play account deletion/deactivation.

## User-generated content (post a flyer)

- **Photos**: One poster image (jpeg/png/webp, max 5 MB). Moderated on first post; later posts from an approved account go live immediately.
- **Map pin (latitude/longitude)**: User-chosen point so others can open Directions. Not continuous device GPS collection.
- **Optional physical address text**: Only if the user types it.
- **Report**: Flyer gallery includes **Report this flyer** (email to support with flyer id).

## Declarations (typical)

- **Personal info**: Email (account); optional phone if the poster adds it.
- **Photos / videos**: Collected to display the 24-hour poster.
- **Location**: Precise location only when the user **manually** drops a pin. No background location for this feature.
- **Account info**: Stored to enforce one free community flyer, image-slot extras, and moderation.

## Retention

Flyers expire 24 hours after publish. Expired poster files are deleted by the server. Taking a flyer down early does not reset the 24-hour community cooldown.

## Mapbox

Map pin picker uses Mapbox (same as discoveries). Follow Mapbox’s terms; no extra Play category unless Mapbox telemetry is enabled.
