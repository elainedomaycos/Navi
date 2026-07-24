# NAVI — Design System Reference
> **For agents, developers, and future phases.** Every visual decision in this document is derived from the approved prototype (screens 0–9). Do not deviate without explicit instruction.

---

## 1. Project Identity

| Property | Value |
|---|---|
| App name | **Navi** |
| Tagline | *navigate your future* |
| Target users | Filipino IT students (Service Management & Business Analytics majors) |
| Platform | Flutter (web + mobile) |
| Tone | Friendly, encouraging, playful — never corporate or intimidating |
| Mascot style | Round blob characters with faces, each with a distinct color and personality |

---

## 2. Color Tokens

All colors are defined in `lib/core/theme/app_colors.dart`. Always import from there — never hardcode hex values inline.

### Brand Colors
```dart
NaviColors.primary       // #3D3580 — deep navy-purple. CTAs, active states, headings
NaviColors.primaryLight  // #7E6DB0 — medium purple. Secondary text, agent names, icons
NaviColors.primaryPale   // #E0DCF5 — lavender tint. Chip backgrounds, progress track, borders
```

### Backgrounds
```dart
NaviColors.background    // #F5F3F0 — soft off-white. All scaffold backgrounds
NaviColors.surface       // #FFFFFF — pure white. Cards, sheets, tiles
```

### Sparkle Accents
Used for mascot tints, badge backgrounds, and decorative elements. Each maps to a mascot.
```dart
NaviColors.sparkBlue     // #81D4FA — Byte
NaviColors.sparkTeal     // #80CBC4 — Flux
NaviColors.sparkGreen    // #A5D6A7 — Echo
NaviColors.sparkYellow   // #FFD54F — Orbit
NaviColors.sparkPurple   // #B39DDB — Nova
NaviColors.sparkPink     // #EF9A9A — decorative / splash sparkles
```

### Demand / Status Colors
```dart
NaviColors.matchHigh     // #4CAF50 — green. High demand, positive indicators
NaviColors.matchMed      // #FFA726 — amber. Medium demand, warnings
NaviColors.matchLow      // #EF5350 — red. Low demand, alerts
```

### Text Colors
```dart
NaviColors.textDark      // #2C2560 — primary text, headings
NaviColors.textMid       // #7E6DB0 — secondary text, subheadings
NaviColors.textLight     // #9E95C7 — tertiary text, labels
NaviColors.textMuted     // #B0AAC8 — placeholder, disabled, hints
```

---

## 3. Typography

Font family: **Nunito** (Google Fonts). All weights are loaded in `pubspec.yaml`.

All styles defined in `lib/core/theme/app_text_styles.dart`.

| Token | Size | Weight | Color | Use |
|---|---|---|---|---|
| `displayLarge` | 32px | 800 | textDark | App logo / hero text |
| `heading1` | 24px | 700 | textDark | Screen titles ("Your Top Career Matches") |
| `heading2` | 20px | 700 | textDark | Section headings, card titles |
| `bodyLarge` | 16px | 400 | textDark | Primary body, card descriptions |
| `bodyMedium` | 14px | 400 | textMid | Secondary body, agent messages |
| `label` | 13px | 600 | textLight | Chips, tags, metadata, sub-labels |
| `button` | 16px | 700 | white | CTA button labels |
| `tagline` | 16px | 600 | primaryLight | Splash tagline only |

### Typography rules
- **Never** use a font other than Nunito anywhere in the app.
- **Weight 900** is used for emphasis within existing styles: `.copyWith(fontWeight: FontWeight.w900)`.
- Headings on screens like Analyzing use w800 on heading1 for extra punch.
- Agent names within `Text.rich` are always `primaryLight` + `w900`.
- Salary ranges and key metrics: `textDark` + `w900`.

---

## 4. Spacing & Layout

### Screen padding
```dart
// Standard screen padding (used on most screens)
padding: EdgeInsets.fromLTRB(18, 16, 18, 24)

// Top-heavy screens (Analyzing, Feedback)
padding: EdgeInsets.fromLTRB(20, 22, 20, 20)
```

### Component spacing rhythm
| Gap | Usage |
|---|---|
| `4px` | Between label and subtext |
| `6–8px` | Inside card between elements |
| `10–12px` | Between list items / tiles |
| `14–16px` | Between card sections |
| `18–20px` | Between major content blocks |
| `24px` | Before bottom CTAs |

### Border radius system
| Radius | Usage |
|---|---|
| `10px` | Small chips, rank badges |
| `14px` | Icon buttons (back, close) |
| `16px` | Feedback chip tiles, pickers |
| `18px` | Standard cards, buttons, progress bar |
| `20px` | Info cards (Market Intelligence, Why Match) |
| `22px` | Top match card |
| `100px` | Pills, badges, progress bar track |

---

## 5. Card System

There are three levels of cards in Navi. Always match the correct level to the content.

### Level 1 — Feature Card (top match, hero card)
```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: Color(0xFFE5DEF8)),
)
// padding: 16px all sides
```

### Level 2 — Standard Card (compact tiles, info blocks)
```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18 or 20),
  border: Border.all(color: Color(0xFFEAE4F8)),
)
// padding: 12–16px
```

### Level 3 — Tinted Accent Card (agent cards, Nova hint, analyzing)
```dart
decoration: BoxDecoration(
  color: agent.tint.withValues(alpha: 0.12–0.16),
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: agent.tint.withValues(alpha: 0.3)),
)
```

### Active / selected state
```dart
border: Border.all(
  color: NaviColors.primaryPale,  // or primaryLight for feedback chips
  width: 2,                        // 1.5 for chips
)
```

---

## 6. Buttons

### Primary CTA (FilledButton) — always full width
```dart
FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: NaviColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
)
// Label: text + SizedBox(width: 10) + Icon (size 18)
```

### Secondary (OutlinedButton) — full width
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: NaviColors.primary,
    side: BorderSide(color: NaviColors.primaryLight),
    padding: EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
)
```

### Icon buttons (back, close, menu)
```dart
IconButton.styleFrom(
  backgroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
)
// Icon color: NaviColors.textDark
```

### Loading state inside button
```dart
// Replace label with:
Row(children: [
  SizedBox(width: 18, height: 18,
    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
  SizedBox(width: 10),
  Text('Agent is working...'),
])
```

---

## 7. Mascots & Agents

Each AI agent has a fixed identity. Never swap mascots between agents.

| Agent | Mascot file | Spark color | Personality |
|---|---|---|---|
| **Byte** | `assets/images/mascots/byte/byte 1.png` | `sparkBlue` | Skills analyzer |
| **Flux** | `assets/images/mascots/flux/flux 1.png` | `sparkTeal` | Job opportunity explorer |
| **Echo** | `assets/images/mascots/echo/echo 1.png` | `sparkGreen` | Career path matcher |
| **Orbit** | `assets/images/mascots/orbit/orbit 1.png` | `sparkYellow` | Roadmap builder |
| **Nova** | `assets/images/mascots/nova/nova 1.png` | `sparkPurple` | Recommendation refiner |

### Mascot container pattern
```dart
Container(
  height: 54, width: 54,           // 46px for compact tiles
  decoration: BoxDecoration(
    color: agent.tint.withValues(alpha: 0.16),
    shape: BoxShape.circle,
  ),
  child: Padding(
    padding: EdgeInsets.all(5),
    child: Image.asset(agent.asset, fit: BoxFit.contain),
  ),
)
```

### Career mascot assignments (Results / Roadmap)
| Career | Mascot | Tint |
|---|---|---|
| Service Manager | Orbit | sparkYellow |
| Business Analyst | Echo | sparkGreen |
| Data Analyst | Byte | sparkBlue |
| Project Manager | Nova | sparkPurple |
| Systems Analyst | Flux | sparkTeal |

---

## 8. Badges & Chips

### Confidence / demand badge
```dart
// Filled color badge (rounded pill)
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.14),
    borderRadius: BorderRadius.circular(100),
  ),
  child: Text(label,
    style: NaviTextStyles.label.copyWith(
      color: color, fontWeight: FontWeight.w900, fontSize: 12)),
)

// Compact variant: horizontal: 8, vertical: 5, fontSize: 11
```

### Demand color mapping
```dart
'High Demand'   → NaviColors.matchHigh   // green
'Medium Demand' → NaviColors.matchMed    // amber
'Low Demand'    → NaviColors.matchLow    // red
// confidence badge always uses NaviColors.matchHigh
// demand label uses NaviColors.primaryLight
```

### Employer chip
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  decoration: BoxDecoration(
    color: Color(0xFFF7F4FF),
    borderRadius: BorderRadius.circular(100),
  ),
  child: Text(label,
    style: NaviTextStyles.label.copyWith(
      color: NaviColors.textDark, fontWeight: FontWeight.w800)),
)
```

### Rank badge
```dart
// Rank 1 (gold circle)
Container(
  height: 40, width: 40,
  decoration: BoxDecoration(color: NaviColors.sparkYellow, shape: BoxShape.circle),
  child: Text('1', style: NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900)),
)

// Rank 2+ (small rounded square)
Container(
  height: 28, width: 28,
  decoration: BoxDecoration(
    color: NaviColors.primaryPale,
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text('2', style: NaviTextStyles.label.copyWith(color: NaviColors.primary, fontWeight: FontWeight.w900)),
)
```

---

## 9. Progress & Loading

### Linear progress bar (splash + quiz)
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(100),
  child: LinearProgressIndicator(
    value: _progress,           // null for indeterminate
    minHeight: 7,
    backgroundColor: NaviColors.primaryPale,
    valueColor: AlwaysStoppedAnimation<Color>(NaviColors.primary),
  ),
)
// Horizontal padding: 48px on splash, 0 on quiz stepper
```

### Agent activity indicator (Analyzing screen)
```dart
SizedBox(
  width: 22, height: 22,
  child: CircularProgressIndicator(
    strokeWidth: 3,
    value: active ? null : 0,   // spinning if active, empty if not
    color: NaviColors.primary,
    backgroundColor: NaviColors.primaryPale,
  ),
)
```

### "This usually takes 20–30 seconds" banner
```dart
Container(
  width: double.infinity,
  padding: EdgeInsets.symmetric(vertical: 14),
  decoration: BoxDecoration(
    color: NaviColors.primaryPale,
    borderRadius: BorderRadius.circular(18),
  ),
  child: Text('...', textAlign: TextAlign.center,
    style: NaviTextStyles.label.copyWith(
      color: NaviColors.primary, fontWeight: FontWeight.w800)),
)
```

---

## 10. Bottom Navigation

4 tabs in fixed order. Never add or remove tabs.

| Index | Label | Icon (inactive) | Icon (active) |
|---|---|---|---|
| 0 | Home | `Icons.home_outlined` | `Icons.home_rounded` |
| 1 | Roadmap | `Icons.map_outlined` | `Icons.map_rounded` |
| 2 | Explore | `Icons.explore_outlined` | `Icons.explore_rounded` |
| 3 | Profile | `Icons.person_outlined` | `Icons.person_rounded` |

- Active tab icon + label: `NaviColors.primary`
- Inactive: `NaviColors.textMuted`
- Background: `Colors.white`
- No elevation shadow

---

## 11. Screen Headers

### Type A — Logo + close (Results)
```dart
Row(children: [
  Image.asset('assets/images/navi_logo.png', height: 38),
  Spacer(),
  IconButton(icon: Icon(Icons.close_rounded), ...),
])
```

### Type B — Back arrow + title + subtitle (Feedback, Compare)
```dart
Row(children: [
  IconButton(icon: Icon(Icons.arrow_back_rounded), ...),
  SizedBox(width: 12),
  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Screen Title', style: NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900)),
    Text('Subtitle', style: NaviTextStyles.label),
  ]),
])
```

### Type C — Title only (Home, Roadmap, Explore, Profile within tab shell)
```dart
Text('Screen Title', style: NaviTextStyles.heading1.copyWith(fontWeight: FontWeight.w900))
// Padding: fromLTRB(18, 16, 18, 0)
```

---

## 12. Animations

All animations use the `flutter_animate` package. Import: `package:flutter_animate/flutter_animate.dart`.

### Standard entry animations
```dart
// Fade + slide down (logo, hero elements)
.animate()
.fadeIn(duration: 600.ms)
.slideY(begin: -0.12, end: 0, curve: Curves.easeOut)

// Fade + slide up (characters, bottom content)
.animate(delay: 500.ms)
.fadeIn(duration: 700.ms)
.slideY(begin: 0.08, end: 0, curve: Curves.easeOut)

// Fade only (taglines, secondary content)
.animate(delay: 300.ms)
.fadeIn(duration: 500.ms)
```

### AnimatedContainer (cards, chips — state changes)
```dart
AnimatedContainer(duration: Duration(milliseconds: 200), ...)
// Use for: selected/unselected chip transitions, agent card active state
```

### AnimatedSwitcher (loading messages)
```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 400),
  child: Text(message, key: ValueKey(messageIndex)),
)
```

---

## 13. Sparkle Widget

Reusable 4-pointed star. Located at `lib/core/widgets/sparkle_widget.dart`.

```dart
SparkleWidget(color: NaviColors.sparkPurple, size: 12)

// Standard sizes:
// 10px — small decorative (splash row)
// 12px — tagline flanking
// 13–14px — medium decorative
```

---

## 14. Screen-by-Screen Quick Reference

| Screen | Key colors | Key widgets | Navigation |
|---|---|---|---|
| **0 Splash** | primary, background | Stack(bg image, logo, characters, progress bar) | Auto → Home after load |
| **1 Home** | primary, surface | Feature list, mascot row, Start CTA | pushReplacement → Quiz |
| **2 Quiz** | primary, primaryPale | Stepper, question cards, option tiles | push → Analyzing |
| **3 Analyzing** | primary, agent tints | AgentCard list, CircularProgressIndicator | pushReplacement → Results |
| **4 Results** | matchHigh, primary | TopMatchCard, CompactMatchTile, MarketIntel, WhyMatch | pop(result) → Home/Roadmap |
| **5 Roadmap** | primary, sparkYellow | Timeline, MilestoneCard, SkillGapChip | Tab nav |
| **6 Feedback** | sparkPurple, primaryPale | NovaCard, FeedbackChipTile, TextField | pop(refined result) → Results |
| **7 What-If** | matchHigh, primary | CareerPicker dropdown, CompareTable, BestForCard | pop → Results |
| **8 Explore** | primary, demand colors | SearchBar, FilterChips, CareerListTile | Tab nav |
| **9 Profile** | primary, sparkBlue | AvatarSection, TopMatchCard, ProgressChecklist | Tab nav |

---

## 15. File & Import Conventions

```
lib/
  core/
    theme/
      app_colors.dart       → NaviColors.*
      app_text_styles.dart  → NaviTextStyles.*
      app_theme.dart        → NaviTheme.theme
    widgets/
      sparkle_widget.dart   → SparkleWidget
      navi_button.dart      → NaviButton (if extracted)
  features/
    splash/splash_screen.dart
    home/home_screen.dart
    quiz/
      quiz_screen.dart
      quiz_session.dart     → QuizSession, QuizAnswer
    results/
      analyzing_screen.dart
      recommendation_engine.dart → RecommendationEngine
      recommendation_result.dart → RecommendationResult, CareerRecommendation
      results_screen.dart
    roadmap/roadmap_screen.dart
    feedback/
      feedback_screen.dart
      feedback_chips.dart   → FeedbackChip, feedbackChips
    compare/compare_screen.dart
    explore/explore_screen.dart
    profile/profile_screen.dart

assets/
  images/
    navi_logo.png
    navi_characters.png
    navi_background.png
    mascots/
      byte/byte 1.png
      flux/flux 1.png
      echo/echo 1.png
      orbit/orbit 1.png
      nova/nova 1.png
  fonts/
    Nunito-Regular.ttf
    Nunito-SemiBold.ttf
    Nunito-Bold.ttf
    Nunito-ExtraBold.ttf
  data/
    ph_careers.json
```

### Import order (follow this in every file)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // if animations used

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/sparkle_widget.dart';      // if sparkles used

import '../quiz/quiz_session.dart';                   // feature-level imports
import '../results/recommendation_result.dart';
```

---

## 16. Do's and Don'ts

### ✅ Do
- Always use `NaviColors.*` constants — never hardcode hex values
- Always use `NaviTextStyles.*` as the base, `.copyWith()` to adjust
- Always use `BoxFit.contain` for mascot images inside their containers
- Use `withValues(alpha: x)` for transparency (not deprecated `withOpacity`)
- Keep all card borders using the `Color(0xFFEAE4F8)` or `Color(0xFFE5DEF8)` light purple tint
- Use `FilledButton` for primary actions, `OutlinedButton` for secondary
- Keep button `borderRadius` at `18`
- Pair every mascot with its correct `sparkColor` for tinted containers

### ❌ Don't
- Don't use any font other than Nunito
- Don't use `Colors.blue`, `Colors.green`, or Material defaults — always use NaviColors
- Don't add `elevation` or shadows to cards — use border only
- Don't use `withOpacity()` — use `withValues(alpha: x)` instead
- Don't use `MediaQuery` for font scaling — keep text sizes fixed
- Don't mix mascot/agent assignments — Byte is always Byte, Nova is always Nova
- Don't use `AppBar` — all screens use custom headers in the body
- Don't use `SnackBar` for feedback — use inline state changes

---

*Last updated: Phase 5 complete (Splash → Home → Quiz → Analyzing → Results → Feedback → What-If)*
*Next: Phase 6 — Profile summary + session memory*
