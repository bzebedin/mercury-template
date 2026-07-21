# GeoBonus — Live-Integration Status (Handover)

Stand: 2026-07-21. Site **live** unter `https://www.geobonus.at/de/…` (OpenCms-Instanz
`workplace.mapexplorer.com` / Modul `com.mapexplorer`). Vorgänger-Doc `STATUS-geobonus-homepage.md`
beschreibt nur den lokalen Pre-Integration-Stand — **dieses Doc ist die aktuelle Wahrheit.**

Design of Truth = `konzept/geobonus-website/design-referenz/*.html` (index, oesterreich,
mein-standort, ueber-uns, kontakt, agb, impressum + `assets/site.css`).

## Seiten (alle Site `www.geobonus.at`, Sprache `/de/`)

| URL | Template | Theme | Status |
|---|---|---|---|
| `/de/` (Homepage) | mercury-geobonus-hp | theme-geobonus-homepage | **live**, Hero + Produktliste befüllt |
| `/de/mein-standort/` | mercury-geobonus-hp | s.o. | **live**, Kopf+Chart-Hintergrund fertig; Showcase-Content offen |
| `/de/digitale-gemeinde/` | mercury-geobonus-hp | s.o. | leer, bereit. Content: Bundesland-Grid + Referenzen |
| `/de/ueber-uns/` | mercury-geobonus-hp | s.o. | leer, bereit |
| `/de/kontakt/` | mercury-geobonus-hp | s.o. | leer, bereit |

Alle Seiten: Property `template=/system/modules/com.mapexplorer/templates/mercury-geobonus-hp.jsp`
und `mercury.theme=/system/modules/com.mapexplorer/css/theme-geobonus-homepage.min.css`.

## Template `mercury-geobonus-hp.jsp`

VFS: `/system/modules/com.mapexplorer/templates/mercury-geobonus-hp.jsp`
Lokaler Mirror (hier editieren, dann pushen): `~/IdeaProjects/olmap/opencms/system/modules/com.mapexplorer/templates/mercury-geobonus-hp.jsp`

- Emittiert GeoBonus-Chrome: Header/Nav, Header-CTA „Projekt anfragen", Mobile-Panel, Projekt-Modal, Footer.
- Content-Container: `<cms:container name="mercury-page" type="area" maxElements="30">`.
- Nav-Fallback (5 Links, hardcoded) + editierbarer `nav-main`-Container (GeoBonus-Nav-Formatter für
  Typ `m-navigation`). Nav-Links: `#produkte` (HP-Anchor), `/de/mein-standort`, `/de/digitale-gemeinde`,
  `/de/ueber-uns`, `/de/kontakt`.
- Fonts (Fraunces/General Sans/IBM Plex Mono) per `<link>` im `<head>`.
- **Per-Page-Style-Hook** (neu): liest `contentPropertiesSearch['gb.pagestyle']`.
  Bei `gb.pagestyle=chart` → wrappt Content in `.chart` (Kartenblatt-Hintergrund) + emittiert
  `.std-head` (Eyebrow + H1) + setzt `site-header--solid`.
  - Heading H1 = Page-**Title** (editierbar).
  - Eyebrow = Property `gb.eyebrow` (Default „GeoBonus · Europa").
  - **WICHTIG:** `cms:property` hat KEIN `var`-Attribut → Properties immer über die
    `contentPropertiesSearch`-Map lesen (wie `['Title']`), nicht `<cms:property var=…>`.

## Content-Typen (Modul com.mapexplorer)

Schemas `com.mapexplorer/schemas/`, Formatter `com.mapexplorer/formatters/`:
- `m-gb-hero` (Root `M-gb-heroData`) — **befüllt** Homepage (`/sites/www.geobonus.at/.content/m-gb-hero/hero_00001.xml`)
- `m-gb-productlist` (+nested `gb-product.xsd`) — **befüllt** Homepage (productlist_00001.xml, 6 Produkte)
- `m-gb-stategrid` (+nested `gb-statetile.xsd`) — existiert, noch ungenutzt → für digitale-gemeinde
- `m-gb-legal` (+nested `gb-legalsection.xsd`) — existiert
- Nav-Formatter `geobonus-nav.jsp`/`.xml` für bestehenden Typ `m-navigation`, Match `nav-main`
- **DEFERRED**: Typ 4 (Referenzen `m-gb-references`) + Typ 5 (Showcase `m-gb-showcase`) sollen
  Formatter der bestehenden **GeoName/GeoClient**-Typen werden (nicht standalone). Modell noch offen.

Sitemap-Config `/sites/www.geobonus.at/.content/.config`: `<ResourceType>`-Blöcke für die 4 m-gb-Typen
freigegeben (Disabled=false).

## Theme

- Entry `template-src/scss/themes/theme-geobonus-homepage.scss` + Design-Layer
  `template-src/scss/themes/_geobonus-homepage-design.scss` (~1682 Z., 1:1 aus allen Referenz-Seiten).
  Enthält bereits `.chart`, `.std-head`, `.examples`, `.spot`, `.site-header--solid` etc.
- Build: `npm run css` → `build/npm/3_minified/theme-geobonus-homepage.min.css`.
- Deploy-Ziel VFS: `/system/modules/com.mapexplorer/css/theme-geobonus-homepage.min.css`
  (NICHT alkacon-Default — siehe Memory `css-deploy-location`).
- JS: `template-src/js/geobonus-homepage.js` → VFS `com.mapexplorer/resources/js/geobonus-homepage.js`.

## Deploy- & Publish-Workflow (kritisch)

**WebDAV = OFFLINE-Projekt.** Credentials in `~/IdeaProjects/olmap/opencms/.env.local`
(`WEBDAV_BASE`, `WEBDAV_USER`, `WEBDAV_PASS`). Base ≈ `http://workplace.mapexplorer.com:8180/webdav`.

Datei ändern → LOCK → PUT/PROPPATCH → UNLOCK, dann **publish** (sonst nur offline):
```bash
cd ~/IdeaProjects/olmap/audio-map-app/scripts
RESOURCES='[{"folder":"/system/modules/com.mapexplorer/templates/","file":"mercury-geobonus-hp.jsp"}]' \
  CONFIRM=1 node opencms-publish-paths.js
```
`RESOURCES` = JSON-Array `{folder, file}`. Ohne `CONFIRM=1` nur Dry-Run.

**Gotchas (hart erlernt):**
- **deleted-offline blockiert Neuanlage/COPY.** DELETE markiert nur gelöscht-offline; ein COPY aufs
  Ziel wirft dann HTTP 500 `CmsLockException: … not locked by claude` bzw. „Failed to read deleted
  resource". Fix: **erst die Löschung publizieren** (`RESOURCES` mit dem Folder/File), dann COPY.
- **Einzeldatei-COPY einer Container-Page = 500.** Immer **Folder-COPY** (`Depth: infinity`).
  Saubere leere GeoBonus-Page = Folder-COPY von `/de/mein-standort` (leere 297-B-Container-Page,
  hat Template/Theme-Props) — aber sie trägt jetzt `gb.pagestyle=chart`; für Nicht-Chart-Seiten
  Property danach entfernen. Alternativ Seite im OpenCms-Workplace („Neu") anlegen, dann per
  PROPPATCH Template+Theme setzen.
- **`formatter_config`-XML**: WebDAV-PUT gibt Typ `plain`. Stattdessen ein bestehendes
  `formatter_config` per WebDAV-COPY klonen (COPY erhält den Typ), dann Inhalt überschreiben.
- **WEAK-Links in Formatter-Config** brauchen die echte Struktur-ID (MariaDB
  `SELECT STRUCTURE_ID FROM CMS_OFFLINE_STRUCTURE WHERE RESOURCE_PATH LIKE '%x.jsp'`), sonst
  „Invalid jsp specified in formatter".
- **Container-Page nach Editor-Änderung republishen** — Editor speichert offline.

**Debug:** `ssh root@production.mapexplorer.com`, Log
`/var/lib/tomcat/8180-T9-opencms/webapps/ROOT/WEB-INF/logs/opencms.log`. DB `opencms_12_0_0` (MariaDB,
Creds in `WEB-INF/config/opencms.properties`). Schema-Load-Fehler: `grep 'getAllowedContextMap.*m-gb'`.

Schema-Regeln (xmllint fängt sie NICHT): siehe Memory `opencms-xmlcontent-schema-rules`.

## Offene Aufgaben (Priorität oben)

1. **Showcase „Auszug aus Referenzen"** auf `/de/mein-standort` — Content-Modell entscheiden:
   (A) standalone Typ `m-gb-showcase`, (B) GeoName/GeoClient-Formatter, (C) statisch.
   Daten in `design-referenz/mein-standort.html`: 3 Kategorien, ~24 Links
   (Ausflugsziele&Freizeit 6 · Gastronomie&Übernachtung 12 · Betriebe&Institutionen 6),
   je Kachel `.spot` = Name + Pfad `geobonus.at/…` (echte GeoName/GeoClient-Einträge).
   Abschluss `.std-cta`: „Zeige was deinen Standort besonders macht!" + „Projekt anfragen".
2. **Edit-Mode-Header-Fix**: `.opencms-page-editor`-Block in `theme-geobonus-homepage.scss` pinnt den
   Header transparent/weiß → auf Chart-Seiten (mein-standort) ist die Nav im Editor weiß-auf-hell
   (kaum sichtbar). Fix: den Transparent-Override NICHT anwenden wenn `site-header--solid` →
   SCSS-Rebuild (`npm run css`) + CSS deployen. Live nicht betroffen.
3. **Restseiten befüllen**: digitale-gemeinde (Bundesland-Grid `m-gb-stategrid` existiert + Referenzen),
   ueber-uns, kontakt (Referenz-Markup in gleichnamigen `design-referenz/*.html`).
4. **Referenzen/Showcase → GeoName/GeoClient-Formatter** (deferred, größer; braucht Einblick in
   deren Schema).

## Verifikation
- Live-Check je Seite: `curl -s https://www.geobonus.at/de/<x>/ | grep -oc 'site-header\|theme-geobonus-homepage'`
- Chart-Kopf: `... | grep -oc 'class="chart"\|std-head\|site-header--solid'`
