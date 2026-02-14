# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Added styled pills for Entry Fee, Event Type, and Date in Event List card.

### Fixed
- Service details page now correctly calculates and displays **Open/Closed** status based on operating hours, and uses consistent 12-hour time formatting (AM/PM) like Business details.

### Changed
- Updated `CurrentEventsScreen` event card layout to move Entry Fee to the top right and improve content organization to prevent overlapping.
- Refactored event card metadata into reusable pill widgets.
- Landing page stats now use the dedicated `GET /api/stats/summary` endpoint (avoids 400 errors before a town is selected).
- Fixed Android release builds by adding `INTERNET` permission to the main manifest (required for Azure API access).

