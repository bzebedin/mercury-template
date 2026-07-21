# GeoBonus Homepage — Umsetzungsstatus (Theme `geobonus-homepage`)

Autonom abgearbeitet aus `HANDOVER-PROMPTS.md`. **Alles lokal, keine Commits, kein OpenCms-Publish.**
Design of Truth = `design-referenz/` (site.css, index/oesterreich/mein-standort/… + assets).

## Was fertig ist (lokal, buildbar, verifiziert)

### 1. Neues Theme `geobonus-homepage` — Design-System komplett (Phase 1 ✔, große Teile 2–5)
- `template-src/scss/themes/theme-geobonus-homepage.scss` — Mercury-Theme-Entry: mappt die
  GeoBonus-Tokens auf Mercury-Brand-Variablen, zieht Mercury-Base (`../imports`) und lädt
  danach das Design-Layer (gewinnt via Source-Order).
- `template-src/scss/themes/_geobonus-homepage-design.scss` — **1:1 aus der Referenz portiertes
  Design-System** (1682 Zeilen), zusammengesetzt aus:
  - shared chrome ← `site.css` (Tokens `:root`, Base, Buttons, Header/Nav, Mobile-Panel, Modal, Legal, Footer, Eyebrow, Fade-Text)
  - Hero + Produktliste + Page-Loader ← `index.html`
  - Intro, Österreich-Karte (`.stage/.state/.map`), Bundesland-Picker (`.state-pick*`), Referenzen (`.refs*`) ← `oesterreich.html`
  - Showcase/Spot/Std/Chart ← `mein-standort.html`
  - Bundesland-Tile-Palette (`--tile*`) ← `oesterreich.html :root`
- **Build**: `npm run css` → `build/npm/3_minified/theme-geobonus-homepage.min.css` (461 KB). Grün-Blau-Fade, Buttons, Hero-Scrim, Product-Rows, Refs, State-Picker, Modal, Legal, Spot — alle Klassen im Output verifiziert.
- Getrennt vom Basis-Theme `theme-geobonus` (das unverändert bleibt).

### 2. Chrome-Verhalten (Phase 2, JS ✔)
- `template-src/js/geobonus-homepage.js` — standalone IIFE, **nicht** in `mercury.js` verdrahtet
  (isoliert auf die Homepage). Portiert: Page-Loader, Header-Scroll-State (`.scrolled`),
  Mobile-Menü (aria-expanded, ESC), Hero-Maus-Parallax (pausiert off-screen), Scroll-Reveal
  (`[data-reveal]` + `[data-reveal-stagger]`), Copyright-Jahr, **Projekt-Anfrage-Modal**
  (Gemeinde/Betrieb-Umschaltung, Interessens-Gruppen, mailto-Submit an `info@geobonus.at`, Success-View).
  `node --check` grün.
- Lokal gestaged nach `alkacon.mercury.theme/resources/system/modules/alkacon.mercury.theme/js/geobonus-homepage.js`.

### 3. Assets (Phase 1/4 ✔)
Kopiert nach `alkacon.mercury.theme/resources/system/modules/alkacon.mercury.theme/img/geobonus-homepage/`:
`geobonus-logo.png`, `europe-globe.jpg`, `schautafel-showcase.jpg`.

## Integration in OpenCms (manuelle Schritte — bewusst NICHT ausgeführt: kein Publish)

1. **Fonts im Template-`<head>`** (Handover erlaubt `<link>`; DSGVO → optional self-hosten):
   ```html
   <link rel="preconnect" href="https://fonts.googleapis.com">
   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
   <link rel="preconnect" href="https://api.fontshare.com">
   <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,500;0,9..144,600;1,9..144,500;1,9..144,600&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
   <link href="https://api.fontshare.com/v2/css?f[]=general-sans@400,500,600,700&display=swap" rel="stylesheet">
   ```
   Fallbacks (Georgia/System/Monospace) sind in den Tokens — Layout bleibt ohne Webfonts intakt.
2. **JS laden**: `<script src="/system/modules/alkacon.mercury.theme/js/geobonus-homepage.js" defer></script>`
   (nur auf Homepage-/GeoBonus-Seiten).
3. **Bild-URLs**: im Markup `assets/…` → `/system/modules/alkacon.mercury.theme/img/geobonus-homepage/…` ersetzen.
4. **Deploy + Publish** (wenn gewünscht): `push.sh` der gebauten CSS/JS nach
   `/system/modules/com.mapexplorer/css|js/`, dann Playwright-Publish
   (`opencms-publish-paths.js CONFIRM=1`). Siehe Memory `opencms-publish-cli`.

## Noch offen (bewusst nicht gemacht — braucht laufende OpenCms-Instanz / ist interaktiv)

### Phase 3–5: Content-Formatter (Hero, Produktliste, Bundesland-Grid, Referenzen, Showcase, Rechtstext)
Muster steht (Explore-Inventar): je Content-Type
`schemas/<x>.xsd` + `formatters/display/<x>.jsp` + `formatters/display/<x>-*.xml` (NewFormatter,
`<Type>m-<x></Type>`, `<Key>`, JSP-Link, Match-ContainerTypes, IncludeSettings) +
Resourcetype in `alkacon.mercury.template/resources/manifest.xml` (`<type … name="m-<x>" id="86xx">`
+ `<explorertype>`) + i18n-Keys in `i18n/*.messages_{de,en}`.
Bewusst nicht angelegt: hand-authored OpenCms-XML mit UUIDs/Type-IDs ist ohne laufende Instanz
nicht validierbar und würde beim Modul-Import brechen. **Empfehlung:** Formatter in einer
OpenCms-Dev-Instanz anlegen (Type-IDs frei, UUIDs vom System), JSP + Schema hier aus der
Referenz-Markup-Struktur ableiten.

Komponenten-→-Formatter-Mapping (aus HANDOVER):
| Referenz | Klassen | Mercury-Formatter |
|---|---|---|
| Hero | `.hero`,`.hero-bg/-scrim/-fade`,`.hero-eyebrow-row`,`.cta-row` | „Hero" (Bild, Eyebrow, Koordinaten, Titel, Subtitle, 1–2 CTAs) |
| Produktliste | `.products-section`,`.product-row--digital/--print`,`.product-tag/-name/-desc/-arrow` | „Produktliste" + Element „Produktzeile" (Collector/Liste) |
| Bundesland-Grid | `.state-picker-grid`,`.state-pick--live/--pending` | „Bundesland-Grid" (pflegbare Kachel-Liste, je Kachel verlinkbar) |
| Referenzen | `.refs`,`.refs-toggle*` | „Referenzen" (Disclosure-Liste) |
| Showcase | `.std-*`,`.spot*`,`.chart` | „Showcase" (Bild + Eyebrow + Titel + Text + CTA) |
| Rechtstext | `.legal-*` | „Rechtstext" (Abschnitte, Definitionslisten, Listen) |

### Interaktive Österreich-Karte (oesterreich.html)
CSS ist portiert (`.stage/.state/.state-shape/.map/.stage-readout/.scroll-cue`). **Nicht** portiert:
die scroll-getriebene SVG-Geometrie (Bundesland-Pfade) + Scroll/IntersectionObserver-Logik +
Bundesland→Gemeinden-Disclosure-JS (~700 Zeilen JS/SVG in `oesterreich.html`). Als pflegbarer
Ersatz ist der **`.state-pick`-Grid** (Touch-Fallback der Referenz) drin — genügt für das im
Handover geforderte „Auswahlraster 9 Bundesländer". Die animierte Karte ist ein optionales
Advanced-Feature (eigener JS-Port + SVG-Asset nötig).

### Projekt-Formular-Backend
JS baut korrekten `mailto:`-Entwurf (wie Referenz). Kein Server-Versand — wenn echtes
Server-Formular gewünscht: Mercury-Webform/Contactform-Element (`alkacon.mercury.webform`) statt mailto.

## Verifikation lokal
- `npm run css` baut alle Themes inkl. `theme-geobonus-homepage` fehlerfrei.
- Braces-Balance des Design-Partials: 440/440.
- Design-Klassen im Minified-CSS bestätigt (hero-scrim, product-row, refs-toggle, state-pick, spot-name, modal-card, fade-text, legal-h2, btn-accent, mobile-panel).
- `node --check` für die JS grün.
- Optischer Abgleich gegen Referenz im Browser: `cd design-referenz && python3 -m http.server 8743`.
