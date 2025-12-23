# towntrek_flutter

A Flutter project for the TownTrek mobile app.

## Environment (local vs Azure production)

The backend API base URL is configured in `lib/core/config/api_config.dart`.

- **Debug** defaults to local (`localHost`)
- **Profile/Release** defaults to production (Azure)

You can override without changing code using `--dart-define`:
- **Force production**: `--dart-define=TT_ENV=production`
- **Force local**: `--dart-define=TT_ENV=localHost`
- **Force a specific API host** (highest priority): `--dart-define=TT_API_BASE_URL=https://your-api-host`
