# Übergabeprompts — GeoBonus-Website in das OpenCms-Mercury-Template

Diese Prompts sind für den **Claude im Projekt `mercury-template`** (OpenCms Alkacon
Mercury). Sie setzen das fertige Design der statischen Referenz-Site
(`website-design/design-referenz/`) in ein OpenCms-Mercury-Theme + Inhalts-Formatter um.

**Arbeitsweise:** Prompts der Reihe nach geben (Phase 0 → 6). Jede Phase liefert ein
klar abgegrenztes Ergebnis mit Akzeptanzkriterien. Der Mercury-Claude kennt die
Template-Interna (SCSS, Formatter-Config, Schemas) — diese Prompts liefern das
**Design of Truth** und das **Mapping**.

**Quelle (Design of Truth):** die statische Site in `design-referenz/`
- `index.html` (Hero + Produktübersicht)
- `oesterreich.html` (Bundesland-Auswahl + Referenzen)
- `mein-standort.html` (Produkt-Showcase + Referenzen + CTA)
- `ueber-uns.html`, `kontakt.html`
- `agb.html`, `impressum.html` (Legal-Layout)
- `assets/site.css` (komplettes Design-System, 549 Zeilen)
- `assets/site.js` (Header-Scroll, Mobile-Menü, Projekt-Modal, Jahr)
- `assets/` Bilder: `geobonus-logo.png`, `europe-globe.jpg`, `schautafel-showcase.jpg`

> Der Mercury-Claude soll diese Dateien als visuelle/CSS-Referenz **lesen**. Design-Tokens
> unten sind zusätzlich eingebettet, damit nichts verloren geht.

---

## Design-System (verbindlich)

```
Farben
  --green:#00C805   --green-deep:#087A0C   (Logo-Grün; -deep = texttauglich, 5.3:1 auf Papier)
  --blue:#3191D6    --blue-deep:#1E6FA8
  --paper:#FAFAF7   --paper-alt:#F0F1EA    --surface:#FFFFFF
  --ink:#132018     --ink-soft:#54615A     --ink-faint:#5F6E67
  --line:#E2E3D9    --line-strong:#CCCFC2
  --hero-dark:#0A1C15
  Akzent-Verlauf (Text):  --fade:      linear-gradient(100deg,#087A0C 0%,#087A0C 42%,#1E6FA8 100%)
  Akzent-Verlauf (dunkel):--fade-dark: linear-gradient(100deg,#00C805 0%,#00C805 42%,#7CC6F2 100%)

Typografie
  --font-display:'Fraunces'      (Serif, opsz, ital)   — Überschriften/Hero
  --font-body:'General Sans'     (Sans)                — Fließtext/UI
  --font-mono:'IBM Plex Mono'    — Eyebrows/Koordinaten/Labels
  --font-script:'Alex Brush'     — dekorative Akzente

  Fonts laden:
   Google:   https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,500;0,9..144,600;1,9..144,500;1,9..144,600&family=IBM+Plex+Mono:wght@400;500&display=swap
   Fontshare:https://api.fontshare.com/v2/css?f[]=general-sans@400,500,600,700&display=swap
   → Falls CSP/DSGVO das blockt: Fonts selbst hosten (in Mercury-Theme einbetten). Fallbacks stehen im Token.

Layout
  --header-h:76px   --container:1240px   --ease:cubic-bezier(.19,1,.22,1)
  Grundton: hell ("Paper"), viel Weißraum, editorial/premium, ruhig.
```

## Komponenten → Mercury-Mapping

| Static-Komponente (CSS-Klasse) | Zweck | Mercury-Umsetzung |
|---|---|---|
| `.site-header` / `--solid`, `.nav-group`/`.nav-link`, `.header-cta`, `.mobile-panel`, `.menu-toggle` | Sticky-Header, Navigation, Mobile-Menü | Template-Chrome (Header-Formatter / nav-macro) |
| `.hero` (`.hero-bg/-scrim/-fade`, `.hero-eyebrow-row`, `.hero-coords`, `.cta-row`) | Startseiten-Hero mit Globe-Bild | Content-Formatter „Hero" (Bild, Eyebrow, Titel, Subtitle, CTAs) |
| `.products-section` / `.product-row` (`--digital`/`--print`, `.product-tag`, `-name`, `-desc`, `-arrow`) | Produktliste als verlinkte Zeilen | Formatter „Produktliste" + Element „Produktzeile" (Tag, Name, Text, Link, Variante) |
| Bundesland-Auswahl (`oesterreich.html`) | Auswahlraster Bundesländer | Formatter „Bundesland-Grid" (Liste aus Regionen) |
| Referenzen (`oesterreich.html`, `mein-standort.html`) | Referenz-Auszug | Formatter „Referenzen" (Liste) |
| Showcase (`mein-standort.html`) | Produkt-Showcase mit Bild + Claim | Formatter „Showcase" |
| `.modal-*` + `#projectForm` (Gemeinde/Betrieb-Toggle, Interessens-Checks, mailto-Submit) | Projekt-Anfrage-Modal | Mercury-Formular (Formatter + JS) oder Mercury-Contactform-Element |
| `.site-footer` (`.footer-legal`, `.footer-dot`, `.footer-bottom`) | Footer | Template-Chrome (Footer-Formatter) |
| `.legal-*` (`legal-doc/-head/-h2/-sec/-dl/-list/…`) | AGB/Impressum-Layout | Formatter „Rechtstext" (strukturierter Legal-Content) |
| `.btn`,`.btn-primary/-accent/-ghost`, `.eyebrow`(`--fade`), `.fade-text`, `.wrap` | UI-Primitive | globale SCSS-Klassen im Theme |

## Seiten-Inventar

- **Startseite** (`index.html`): Hero + Produktübersicht
- **Österreich** (`oesterreich.html`): „Bundesland wählen" + Referenzen
- **Mein Standort** (`mein-standort.html`): Showcase + „Auszug aus Referenzen" + CTA „Zeige was deinen Standort besonders macht!"
- **Über uns**, **Kontakt** (Firmendaten „Mapexplorer Information Systems GmbH" + Anfrageformular)
- **AGB**, **Impressum** (Legal-Layout)

## JS-Verhalten (aus `site.js` übernehmen)

- Header wird beim Scrollen `--solid` (Klasse via scroll-Listener)
- Mobile-Menü Toggle (`menuToggle` ↔ `mobilePanel`, `aria-expanded`)
- Projekt-Modal: öffnen/schließen (Klick + ESC), Gemeinde/Betrieb-Umschaltung blendet Interessens-Gruppen, Submit baut `mailto:` an `info@geobonus.at` und zeigt Success-View
- Copyright-Jahr automatisch (`copyYear`)

---

## PROMPT 0 — Orientierung & Plan (zuerst geben)

```
Kontext: Ich arbeite im Projekt `mercury-template` (OpenCms Alkacon Mercury). Ziel:
die GeoBonus-Website im neuen Design umsetzen — als Mercury-Theme (Styling) plus
Inhalts-Formatter, sodass Redakteure die Seiten pflegen können.

Design of Truth ist die fertige statische Site unter `design-referenz/` (index.html,
oesterreich.html, mein-standort.html, ueber-uns.html, kontakt.html, agb.html,
impressum.html, assets/site.css, assets/site.js, assets/*.png/jpg). Diese Dateien
sind das verbindliche Ziel-Aussehen.

Aufgabe dieser Phase (NUR Analyse, kein Code):
1. Lies assets/site.css komplett und index.html; extrahiere Design-Tokens, Komponenten
   und Seiten-Struktur.
2. Inventarisiere die vorhandene Mercury-Template-Struktur: wo liegen SCSS/CSS-Theme,
   Formatter-Configs, Content-Schemas (XSD), Layout-/Macro-Dateien? Wie wird ein neues
   Theme/Formatter angelegt?
3. Erstelle einen Umsetzungsplan, der jede Static-Komponente einem Mercury-Artefakt
   zuordnet (Theme-SCSS vs. Formatter vs. Content-Type). Nenne Dateipfade, die du
   anlegen/ändern wirst.
4. Liste offene Entscheidungen (z.B. Fonts extern vs. self-hosted, Formular als
   Mercury-Contactform vs. eigenes Formatter-Formular).

Gib den Plan als Phasenliste zurück. Noch nichts implementieren.
```

## PROMPT 1 — Design-System ins Theme

```
Setze das GeoBonus-Design-System als Mercury-Theme um (Basis-Styling, noch keine
Formatter).

Quelle: design-referenz/assets/site.css (:root-Tokens, Base, Buttons, .eyebrow,
.fade-text, .wrap).

Umsetzung:
- Lege die Farb-, Typo- und Layout-Tokens als SCSS-Variablen/CSS-Custom-Properties im
  Mercury-Theme an (exakt die Werte aus site.css :root — siehe Tokens in der Übergabe).
- Binde die Schriften ein (Fraunces, General Sans, IBM Plex Mono, Alex Brush). Bevorzugt
  self-hosted im Theme (DSGVO/CSP-sicher); sonst per <link> mit den angegebenen URLs.
- Portiere Base-Styles (Papier-Hintergrund #FAFAF7, Ink-Text, Selection, Focus-Ring),
  Button-Varianten (.btn-primary/-accent/-ghost), .eyebrow/.eyebrow--fade, .fade-text,
  Container-Breite 1240px.

Akzeptanz: Eine Test-Seite im Theme zeigt korrekte Schriften, Farben, Button-Stile und
den Grün→Blau-Text-Verlauf (.fade-text) identisch zur statischen Referenz.
```

## PROMPT 2 — Template-Chrome (Header, Nav, Footer, Mobile-Menü, Modal)

```
Baue das Seiten-Chrome als Mercury-Template-Elemente, visuell identisch zur Referenz.

Quelle: Header/Nav/Footer/Mobile-Panel/Modal-Markup in index.html + Verhalten in
site.js; Styles in site.css (.site-header/--solid, .nav-group/.nav-link, .header-cta,
.mobile-panel, .menu-toggle, .site-footer/.footer-legal/.footer-dot/.footer-bottom,
.modal-*).

Umsetzung:
- Sticky-Header (Höhe 76px) mit Logo (assets/geobonus-logo.png), Nav-Links, CTA
  „Projekt anfragen". Scroll-Zustand `--solid` per JS wie in site.js.
- Mobile-Menü (Toggle + Panel, aria-expanded) wie site.js.
- Footer mit Legal-Nav (Impressum/AGB/Datenschutz), Trenner-Dots, automatischem Jahr.
- Projekt-Anfrage-Modal: Formular mit Gemeinde/Betrieb-Umschaltung, Interessens-
  Checkboxen, mailto-Submit an info@geobonus.at, Success-View, ESC/Overlay-Schließen.
  (Entweder als Mercury-Contactform-Element mit angepasstem Formatter oder als eigenes
  Formatter-Formular — nutze, was im Template am wartbarsten ist.)
- JS ins Theme integrieren (Header-Scroll, Menü, Modal, copyYear).

Akzeptanz: Header/Footer/Menü/Modal verhalten und sehen aus wie die statische Site
(Desktop + Mobile). Formular baut korrekten mailto-Entwurf.
```

## PROMPT 3 — Inhalts-Formatter: Hero & Produktliste

```
Erstelle die zwei zentralen Content-Formatter der Startseite.

A) Hero-Formatter (Quelle: <section class="hero"> in index.html)
   Felder: Hintergrundbild, Eyebrow-Zeile (mit Koordinaten-Text .hero-coords, mono),
   Titel (Fraunces, groß), Subtitle, 1–2 CTAs (.cta-row → .btn-primary/-ghost).
   Umsetzung mit .hero-bg/-scrim/-fade-Ebenen wie in der Referenz.

B) Produktliste (Quelle: <section class="products-section"> / .product-row)
   - Sektion mit .eyebrow + Titel + Claim (.fade-text).
   - Wiederholbares Element „Produktzeile": Tag (Digital/Print → Variante
     .product-row--digital/--print), Name, Beschreibung, optionaler Link (.product-row
     als <a> wenn verlinkt, sonst <div>), Pfeil-Icon.
   - Als OpenCms-Liste/Collector pflegbar.

Akzeptanz: Startseite lässt sich im OpenCms-Editor aus Hero + Produktzeilen zusammen-
setzen und rendert pixelnah zur Referenz (Hover-States der Zeilen inkl.).
```

## PROMPT 4 — Inhalts-Formatter: Bundesland-Grid, Referenzen, Showcase

```
Erstelle die Formatter für die Unterseiten.

Quelle: oesterreich.html (Bundesland-Auswahl „Bundesland wählen", Referenzen) und
mein-standort.html (Showcase mit assets/schautafel-showcase.jpg, „Auszug aus
Referenzen", CTA „Zeige was deinen Standort besonders macht!").

- Bundesland-Grid: Auswahlraster (9 Bundesländer) als pflegbare Liste, jede Kachel
  verlinkbar.
- Referenzen: pflegbare Referenz-Liste (Auszug), Layout wie Referenz.
- Showcase: Bild + Eyebrow + Titel + Text + CTA.

Akzeptanz: Beide Unterseiten aus Formattern zusammensetzbar, pixelnah zur Referenz.
```

## PROMPT 5 — Legal-Layout & statische Seiten (AGB, Impressum, Über uns, Kontakt)

```
Setze das Rechtstext-/Info-Layout um.

Quelle: agb.html, impressum.html (.legal-doc/.legal-head/.legal-h2/.legal-sec/
.legal-dl/.legal-list/.legal-intro/.legal-rule …), ueber-uns.html, kontakt.html
(Firmendaten „Mapexplorer Information Systems GmbH" + Projekt-Formular).

- Formatter „Rechtstext" für gut lesbares, strukturiertes Legal-Layout (Abschnitte,
  Definitionslisten, Listen).
- Über-uns- und Kontakt-Seite mit passenden Formattern; Kontakt bindet das
  Projekt-Modal/Formular aus Phase 2 ein.

Akzeptanz: AGB/Impressum sauber typografiert wie Referenz; Kontakt zeigt Firmendaten
+ funktionierendes Anfrageformular.
```

## PROMPT 6 — Zusammenbau, QA, Responsiveness

```
Baue alle Seiten im OpenCms zusammen und prüfe gegen die Referenz.

- Alle Seiten (Start, Österreich, Mein Standort, Über uns, Kontakt, AGB, Impressum)
  aus den Formattern aufbauen, Navigation verdrahten.
- Visuellen Abgleich Desktop + Mobile gegen design-referenz/*.html.
- Prüfen: Fonts laden (kein CSP-Block), Kontraste (Grün nur in -deep-Varianten für
  Text), Fokus-States, aria-Attribute, Hover/Scroll-Verhalten, mailto-Formular.
- Liste verbleibende Abweichungen mit Screenshots.

Akzeptanz: Redaktionell pflegbare GeoBonus-Website im OpenCms, die dem neuen Design
auf allen Seiten entspricht.
```

---

## Hinweise für den Mercury-Claude

- **Grün-Kontrast:** Das reine Logo-Grün `#00C805` erreicht auf Papier nur ~2.2:1 → für
  Text NIE verwenden. Text-Akzente nutzen `--green-deep`/`--fade` (≥4.7:1). Reines Grün
  nur für Flächen/Icons/Dots.
- **Fonts extern:** Google Fonts + Fontshare sind externe Quellen — bei CSP/DSGVO
  self-hosten. Fallbacks sind in den Tokens hinterlegt.
- **Bilder:** `geobonus-logo.png` (Header), `europe-globe.jpg` (Hero), `schautafel-showcase.jpg`
  (Showcase) aus `design-referenz/assets/` übernehmen.
- **Pixelnah heißt pixelnah:** Bei Zweifeln die statische Referenz im Browser öffnen
  (`python3 -m http.server 8743` im design-referenz-Ordner, siehe .claude/launch.json)
  und direkt vergleichen.
