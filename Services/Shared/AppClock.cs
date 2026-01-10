using System;

namespace TownTrek.Services.Shared
{
    /// <summary>
    /// Centralized clock helpers so we consistently interpret Event Start/End dates/times.
    ///
    /// NOTE: Event StartDate/EndDate/StartTime/EndTime are stored without timezone context (local "wall clock").
    /// TownTrek is SA-focused, so we interpret those values in South Africa local time for lifecycle decisions.
    /// </summary>
    internal static class AppClock
    {
        private static readonly Lazy<TimeZoneInfo> EventTimeZone = new(ResolveEventTimeZone);

        internal static DateTime UtcNow() => DateTime.UtcNow;

        internal static DateTime EventNow()
        {
            var utc = UtcNow();
            return ToEventLocal(utc);
        }

        internal static DateTime EventToday() => EventNow().Date;

        internal static DateTime ToEventLocal(DateTime utcDateTime)
        {
            // Treat input as UTC ticks regardless of Kind. This avoids surprises if callers pass Unspecified.
            var utc = DateTime.SpecifyKind(utcDateTime, DateTimeKind.Utc);
            return TimeZoneInfo.ConvertTimeFromUtc(utc, EventTimeZone.Value);
        }

        private static TimeZoneInfo ResolveEventTimeZone()
        {
            // Windows
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("South Africa Standard Time");
            }
            catch
            {
                // ignore and try IANA
            }

            // Linux/macOS
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("Africa/Johannesburg");
            }
            catch
            {
                // Final fallback: UTC (still deterministic, but may differ from SA wall-clock expectations)
                return TimeZoneInfo.Utc;
            }
        }
    }
}

