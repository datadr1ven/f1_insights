# F1 Driver Insights API – OpenF1 + Xano (Production-Ready Public API Challenge)

**Live API**: https://x8ki-letl-twmt.n7.xano.io/api:qQiTXlkq  
**Swagger / OpenAPI docs**: https://x8ki-letl-twmt.n7.xano.io/api:qQiTXlkq/docs  

A real-time Formula 1 driver insights backend built entirely in Xano for the **Xano AI-Powered Backend Challenge** (Production-Ready Public API category).

## What it does
Proxies OpenF1 data (laps, positions, weather) and returns driver-specific, preference-aware insights in one call:

| Endpoint | Purpose | Key Features |
|---------|-------|-------------|
| `GET /f1_driver_meeting_performance` | Raw performance | Pace score, latest position, lap samples |
| `GET /f1_driver_meeting_strategy` | Rule-based strategy | `fanPrefs` multiplier (aggressive / defensive / balanced) + weather penalty |
| `GET /f1_driver_meeting_ai_strategy` | AI-refined tactics | Same as above + natural-language tip from Gemini Flash (rules fallback on quota) |

All three endpoints are **public, rate-limited, cached (30 s), and require no auth** for GET requests.

## Example calls (no key needed)

```bash
# Verstappen – Bahrain 2024 (meeting_key=1160)
curl "https://x8ki-letl-twmt.n7.xano.io/api:qQiTXlkq/f1_driver_meeting_ai_strategy?meeting_key=1160&driver_number=1&fanPrefs=aggressive"
```

Sample response (rainy conditions, aggressive prefs):
```json
{
  "driver_number": "1",
  "latest_position": 1,
  "pace_score": 0.95,
  "personalized_score": 0.82,
  "tip": "Hammer the throttle out of turns – this pace is lethal! Rain on the way – be ready for inters.",
  "applied_preference": "aggressive",
  "weather_summary": {
    "rain": true,
    "air_temp": 18,
    "wind_kph": 14
  },
  "raw_laps_sample": [ … ]
}
```

## How it works
1. **OpenF1 proxy** – three parallel External API Requests (laps, positions, weather)  
2. **Rule engine** – calculates base score, applies `fanPrefs` multiplier and weather penalty (rain = –25 %)  
3. **AI Function** – optional Gemini 1.5 Flash call for natural-language tip (falls back to rule-based tip on quota)  
4. **Caching & safety** – 30-second cache per driver + preference + weather state, 100 req/min rate limit

## Running / testing locally
Everything lives in Xano – no local server needed.  
Just open the Swagger link above or use Postman/cURL.

## Challenge submission post:  
https://dev.to/datadr1ven/f1-driver-strategy-api-ai-refined-tactics-with-xano-4f84

## License
MIT – feel free to fork, extend, or build your own F1 dashboard on top of it.

Happy racing!
