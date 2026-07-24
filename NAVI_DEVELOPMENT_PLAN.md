# Navi Development Plan

## Current State

**Code health:** `dart analyze` reports 4 info-level lint issues (prefer_const_constructors) — zero errors.
**Test status:** 24 passing tests covering QuizSession, RecommendationEngine, and SessionMemoryService.

### What's built (Phase 1 complete)

| Feature | Status | File(s) |
|---|---|---|
| Theme system (colors, text styles, theme) | Done | `lib/core/theme/` |
| Sparkle widget | Done | `lib/core/widgets/sparkle_widget.dart` |
| Bottom nav bar (4 tabs) | Done | `lib/core/widgets/bottom_nav_bar.dart` |
| Gemini AI service | Done | `lib/core/services/gemini_service.dart` |
| Session memory (SharedPreferences) | Done | `lib/core/services/session_memory_service.dart` |
| Splash screen | Done | `lib/features/splash/splash_screen.dart` |
| Home screen + tab shell | Done | `lib/features/home/home_screen.dart` |
| Quiz (5 questions) | Done | `lib/features/quiz/quiz_screen.dart` |
| Quiz data models | Done | `lib/features/quiz/quiz_session.dart` |
| Analyzing screen (agent activity) | Done | `lib/features/results/analyzing_screen.dart` |
| Recommendation engine (AI + rule fallback) | Done | `lib/features/results/recommendation_engine.dart` |
| Recommendation data models | Done | `lib/features/results/recommendation_result.dart` |
| Results screen (top 3, market intel, why match) | Done | `lib/features/results/results_screen.dart` |
| Roadmap screen (timeline + skill gaps) | Done | `lib/features/roadmap/roadmap_screen.dart` |
| Roadmap engine | Done | `lib/features/roadmap/roadmap_engine.dart` |
| Roadmap data models | Done | `lib/features/roadmap/roadmap_plan.dart` |
| Feedback screen (Nova + chips + text) | Done | `lib/features/feedback/feedback_screen.dart` |
| Feedback chip data | Done | `lib/features/feedback/feedback_chips.dart` |
| Compare screen (side-by-side) | Done | `lib/features/compare/compare_screen.dart` |
| Explore screen (search + filter) | Done | `lib/features/explore/explore_screen.dart` |
| Profile screen | Done | `lib/features/profile/profile_screen.dart` |

---

## Phase 2 — Hardening & Data Layer (2–3 weeks)

### 1. Create `assets/data/ph_careers.json`
**Why:** Career data is hardcoded in 3+ places (recommendation_engine, explore_screen, gemini_service prompts). A single JSON source eliminates duplication and makes updates easy.
**What to do:**
- Move all 5 career profiles (id, title, salary, demand, trend, summary, mascot, tint, employers, weights, reasons, milestones, skill gaps) into a single JSON file.
- Create a `CareerDataService` that loads and caches it.
- Refactor recommendation_engine, explore_screen, roadmap_engine, and gemini_service to read from the service.

### 2. Unused dependency cleanup
**Why:** 3 declared dependencies are unused.
- `flutter_riverpod` / `riverpod_annotation` — not imported anywhere
- `go_router` — not imported anywhere
- `hive_flutter` — not imported anywhere (uses SharedPreferences instead)

**Decision:** Either integrate them or remove from pubspec.yaml to avoid bloat.
- ✅ **Recommendation:** Add Riverpod (state management for session + results) and go_router (typed routes). Drop hive if SharedPreferences suffices.

### 3. Add Riverpod state management
**Why:** Session and results are currently threaded through widget constructors (prop drilling). Riverpod provides a clean global state layer.
**What to do:**
- Create a `session_provider.dart` and `result_provider.dart` in `lib/core/providers/`.
- Refactor HomeScreen to use `ConsumerWidget` / `ConsumerStatefulWidget`.
- Eliminate the `session`, `result`, `onStartAssessment` threading across 4 tab pages.

### 4. Add go_router
**Why:** Currently uses raw Navigator.push with custom routes. go_router gives deep linking, back-button handling, and a single route table.
**What to do:**
- Define routes: `/splash`, `/home`, `/quiz`, `/analyzing`, `/results`, `/feedback`, `/compare`.
- Replace all `Navigator.of(context).push` / `pop` calls.
- Keep the bottom nav as a `ShellRoute`.

### 5. Missing quiz answer mappings
**Bug:** The following answerIds exist in quiz options but are NOT handled in recommendation_engine `_scoreCareers` weight maps:
- `still_exploring` (question: major)
- `designing_visuals` (question: interests)
- `creative_thinking` (question: skills)

These answers get zero weights, missing the scoring system entirely.
**Fix:** Add weight entries for these answerIds in each career profile, or treat them as neutral/no-op.

### 6. Home screen mascot colors don't match design system
**Bug:**
| Mascot | Current (home_screen.dart) | Design spec |
|--------|---------------------------|-------------|
| Echo | sparkTeal (#80CBC4) | sparkGreen (#A5D6A7) |
| Flux | sparkYellow (#FFD54F) | sparkTeal (#80CBC4) |
| Orbit | sparkGreen (#A5D6A7) | sparkYellow (#FFD54F) |

**Fix:** Swap the tint values in `_mascots` list at line 610-641.

---

## Phase 3 — Feature Polish (2–3 weeks)

### 7. Offline fallback AI mode
**Why:** If Gemini API key is missing or rate-limited, the app silently falls back to rule-based scoring. This is good, but the user doesn't know.
**Fix:**
- Show a banner: "Using local matching (AI unavailable)" when in rule-based mode.
- Cache the last successful AI response in SharedPreferences so repeat visits show AI results.

### 8. Refined loading states
- Home screen: skeleton loading while `_restoreSession()` runs.
- Results screen: shimmer placeholders for cards that haven't animated in.
- Compare screen: disabled dropdowns while data loads.

### 9. Better error handling
- The `GeminiService` currently returns `null` on any error — the user sees a "retry" screen but no details.
- Log the actual error (print/debug) and show a more helpful message.

### 10. Feedback chip separator spacing
**Bug:** The feedback chips in `feedback_screen.dart` are spread into the column with `...feedbackChips.map(...)` but have no spacing between them. They use `margin: const EdgeInsets.only(bottom: 10)` inside the tile, but this doesn't apply to the last item.
**Fix:** Add `SizedBox(height: 10)` between each chip using a `separatorBuilder` pattern.

### 11. Enhanced roadmap progress markers
- Make the timeline markers show a dotted/stepped line between years.
- Add an "estimated completion date" under each year label.
- Show which milestones are completed vs pending (checkmark vs circle).

### 12. Compare screen: add pros/cons
- Currently compares only Match %, Salary, Demand, and Difficulty.
- Add a "Pros" / "Cons" section derived from each career's weights vs user's answers.

---

## Phase 4 — New Features (3–4 weeks)

### 13. Onboarding flow
- First-time user sees a 3-screen carousel: "Welcome to Navi → How it works → Ready?"
- Store a `has_seen_onboarding` flag in SharedPreferences.

### 14. Career detail page (not just bottom sheet)
- The Explore screen currently opens a bottom sheet. Build a full-page CareerDetailScreen with:
  - Large mascot + header
  - PH market data (demand, salary, trend)
  - Top employers map (PH regions)
  - Day-in-the-life description
  - Required skills / certifications
  - Similar careers
  - "Compare with my top match" CTA

### 15. PH job board integration (future)
- Use a lightweight API (e.g., JobStreet PH RSS, or a curated JSON feed) to show real-time job postings.
- Show "X openings right now" on each career detail card.

### 16. Share results
- Generate a shareable image (screenshot-style) of the top 3 matches.
- Use `share_plus` package to share as PNG.
- Include app tagline + QR code to navi.app.

### 17. PDF roadmap export
- Generate a PDF of the roadmap using `pdf` package.
- Include: header, timeline, skill gap table, top match summary.

### 18. Push notifications
- `firebase_messaging` for milestone reminders: "Time to start Year 2 milestones!"
- Weekly check-in: "How's your roadmap progress?"

### 19. Filipino / Tagalog localization
- Add `flutter_localizations` + ARB files for `tl` and `en`.
- Quiz questions, chip labels, and results descriptions in both languages.

### 20. Dark mode
- Add a `ThemeMode` toggle in Profile.
- Define `app_colors_dark.dart` variants.
- Use `NaviTheme.theme` and `NaviTheme.darkTheme`.

---

## Phase 5 — Infrastructure (1–2 weeks)

### 21. CI/CD
- GitHub Actions workflow: `flutter analyze` + `flutter test` on PR.
- `flutter build apk` / `flutter build ios` on merge to main.
- Codemagic or GitHub Actions deploy to Firebase App Distribution.

### 22. Performance optimization
- Lazy-load mascot images (they're heavy PNGs).
- Consider converting mascot PNGs to WebP.
- Caching: `CachedNetworkImage` or precaching assets after splash.

### 23. Accessibility
- Add `Semantics` to mascot images, icons, and interactive elements.
- Ensure minimum touch target sizes (48x48).
- Test with screen reader (TalkBack / VoiceOver).

### 24. Analytics
- Add `firebase_analytics`.
- Track: quiz completion, top match viewed, feedback given, compare used, roadmap viewed.
- No PII tracking.

---

## Bugs & Technical Debt

| Priority | Issue | Location | Fix |
|----------|-------|----------|-----|
| High | `still_exploring` has no weights in any career | `recommendation_engine.dart` | Add neutral weights (+5 to all) or treat as no-op |
| High | `designing_visuals` / `creative_thinking` have no weights | same | Add weights for design-related careers (e.g., BA gets +8) |
| High | Feedback chips missing spacing | `feedback_screen.dart:124` | Add `SizedBox(height: 10)` between chips |
| Medium | Home screen mascot tints wrong | `home_screen.dart:610-641` | Swap Echo↔Flux↔Orbit tints per design spec |
| Medium | Hardcoded career data in 3 files | multiple | Consolidate into `ph_careers.json` |
| Low | 4 lint infos about `const` | compare, feedback screens | Add `const` keyword |
| Low | `_mascots` includes Brit but never referenced | `home_screen.dart` | Intentional (decorative), mark as such |
| Low | No error logging in GeminiService | `gemini_service.dart` | Add `debugPrint` on catch |

---

## Recommended Sprint Plan

| Sprint | Focus | Key Deliverables |
|--------|-------|------------------|
| Sprint 1 | Data layer | `ph_careers.json`, `CareerDataService`, fix answer weight gaps |
| Sprint 2 | State management | Riverpod providers, go_router, eliminate prop drilling |
| Sprint 3 | Polish | Fix bugs (colors, spacing, missing weights), loading states |
| Sprint 4 | Onboarding + Share | 3-screen onboarding, share results as image |
| Sprint 5 | Career detail page | Full-page career detail with PH market data |
| Sprint 6 | Localization + Dark mode | Tagalog locale, dark theme |
| Sprint 7 | CI/CD + Performance | GitHub Actions, WebP conversion, accessibility |
| Sprint 8 | Push + PDF | Notifications, PDF export, analytics |

---

## What Else Can We Do? (Bonus Ideas)

1. **AI agent personalities** — Give each mascot a unique chat personality. Byte is logical and terse, Orbit is enthusiastic, Echo asks follow-up questions.
2. **Mock interview mode** — Nova quizzes the user with behavioral questions for their target career.
3. **Peer comparison** — Anonymized: "68% of SM students match with Service Manager as top 1."
4. **Employer spotlight** — Monthly featured PH company with culture, salary data, and recent hires.
5. **Skill marketplace** — Link to free PH resources: TESDA courses, Coursera, Google Career Certificates.
6. **Career journal** — Let students log weekly reflections and track skill growth.
7. **Chat-based quiz** — Instead of static options, let users type free-form and Byte extracts structured answers via NLP.
8. **Alumni network** — "Mapa" feature: see what previous grads from your school/program are doing now.
