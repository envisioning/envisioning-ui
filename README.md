# EnvisioningUI

The distinctive layer shared by [Core](https://github.com/envisioning/CORE-Helper-App)
and Meet. What makes an app read as *Envisioning* — and nothing else.

```swift
.package(path: "../envisioning-ui")
```

## What is in it

| | |
|---|---|
| `EnvisioningAccent` | the lime, its pressed and hovered states, and the ink that goes on it |
| `EnvisioningFilledButtonStyle` | the brand CTA — lime fill, black ink, press outranks hover |
| `EnvisioningBorderedButtonStyle` | its quiet sibling, on system surfaces |
| `EnvisioningSignInButton` | one Envisioning identity label and loading state, with filled/bordered prominence |
| `EnvisioningRadius` | 12 field, 14 control, 18 card |
| `EnvisioningSemantics` | `danger`, `busy`, `publicEvent` |
| `EnvisioningSurface` | the surface ladder — `canvas`, `panel`, `elevated`, `field`, borders, text tones — as `Color`, `NSColor` and `UIColor` from one table; `Token.hex(dark:)` for a stylesheet mirror |
| `EnvisioningMark` | the EV glyph, as a `Shape` |
| `EnvisioningFont` | Envisioning Octa, registered at runtime |
| `EnvisioningWelcomeShell` | shared first-launch mark, wordmark, card geometry, and version placement |
| `EnvisioningWorkspaceTransition` | shared hand-off state after auth and before the workspace is ready |
| `EnvisioningEntryGate` | shared signed-out → preparing → ready root state machine |
| `EnvisioningLoadingState` / `EmptyState` / `RetryState` | canonical blocking and recoverable states |
| `EnvisioningInlineRetry` | compact retry treatment for list rows and banners |
| `EnvisioningHomeTabLabel` | canonical Home label with the EV tab glyph on iOS |
| `EnvisioningLockScreen` | shared biometric-lock cover — quiet by design: glyph, one Unlock button, failure text only when there is one; the system sheet does the explaining |
| `EnvisioningSettingsShell` | shared Account / Preferences / Security / System navigation on iPhone, iPad, and Mac |
| `EnvisioningAppearancePicker` | canonical Auto / Light / Dark control and explanatory copy |
| `EnvisioningAppLockSection` | shared biometric-lock setting, errors, and security explanation |
| `EnvisioningCopy` | canonical sign-in, loading, and common action labels |

## What is deliberately not in it

Surfaces. No `background`, `panel`, `elevated`, `field`, `border`, `primary` or
`secondary`. Those belong to the platform.

Owning surfaces is what drifted Meet away from iOS — twenty-seven sites that turned
system chrome off and repainted it, which cost the scroll-edge treatment, the bar
materials and the separator insets, and bought a 52-line workaround for an alert
bug the hand-rolled presentation created. Re-owning them here would move the drift
rather than remove it.

Two apps do not read as siblings because they share a grey. They read as siblings
because they share a mark, a face, and a lime that behaves the same way in both.

## The accent rule

Lime is a **fill** carrying black ink. It is never ink itself on a light surface.

| pairing | ratio | |
|---|---|---|
| black on `#d6f249` | 16.66:1 | pass |
| black on `#aacc00` | 11.35:1 | pass |
| `#d6f249` as ink on white | 1.26:1 | fail |
| `#aacc00` as ink on white | 1.85:1 | fail |

Darkening does not rescue the foreground case. The first lime clearing 3:1 against
white is `#87992E` — an olive, not the brand. So there is no `EnvisioningAccent.accent`
to reach for: the members are `fill`, `fillPressed`, `fillHover` and `ink`, and a
call site writing `.foregroundStyle(EnvisioningAccent.fill)` reads as wrong on sight.

One value in light and dark. Only the interaction state changes.

## The mark

A `Shape`, not an asset.

The same glyph previously existed as four SVG files across the two repos. They were
verified identical — Core's coordinates are Meet's multiplied by 12.190476, agreeing
to 2.5e-5 — so collapsing them to one path lost nothing.

Drawing it as a `Shape` also fixes a limitation neither app had solved. Meet drew
the glyph in a `Canvas`, which WidgetKit refuses, so it kept a second copy as a
template imageset purely for the tab bar. A `Shape` renders in the app, the tab bar
and a Live Activity alike, at any size, in any tint.

```swift
EnvisioningMark.view(size: 44, tint: EnvisioningAccent.fill)
```

## The font

One variable file carries eighteen faces — nine weights, each in normal and
Expanded width. Every named instance ships a PostScript name, so they resolve
directly by name.

A package cannot use `UIAppFonts`; that key only works from an app's Info.plist. So
`EnvisioningFont.register()` registers the bundled face at runtime, idempotently,
and `octa(_:weight:expanded:)` calls it for you.

```swift
Text("09:41").font(EnvisioningFont.octa(56))
```

Octa is sized fixed, not scaled. It is a display face — a clock, a wordmark — where
reflowing to an accessibility size breaks the layout it anchors. Body text stays on
the system face.

**Canonical source:** the copy vendored here came from Meet, which is newer than
`envisioning-octa/dist` and does not match it. That copy should be published back to
the font repo, and this package should then track it.

## Platform floor

```swift
platforms: [.iOS(.v17), .macOS(.v14)]
```

Meet's floor, not Core's. Core deploys to iOS 26.1 and may use newer API in its own
code — but nothing shared can, or Meet cannot consume it.

## Tests

The package tests pin the claims it makes rather than restating its code: Octa
registers and all eighteen faces resolve by PostScript name; the mark stays
square and centred in a non-square frame; the mark fills its square edge to edge;
black ink clears AA on all three accent states; and the light/dark foreground
accent remains legible.

```
swift test
```
