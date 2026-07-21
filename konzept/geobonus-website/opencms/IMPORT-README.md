# GeoBonus Homepage — Content-Formatter & Schemas (Import-Anleitung)

Phase 3–5 aus `HANDOVER-PROMPTS.md`. **Lokal erstellt, nicht publiziert.** Zielmodul: `com.mapexplorer`
(dort liegen die geobonus.at-Formatter/Schemas). Alles nach Mercury-Konvention (Vorbild:
`alkacon.mercury.template/.../schemas/section.xsd` + `formatters/section/*`).

## Was hier liegt

```
opencms/
  schemas/
    geobonus-hero.xsd         (GbHero: Bild, Eyebrow, Koordinaten, Titel, Titel-Akzent, Subtitle, 1–2 CTA)
    geobonus-productlist.xsd  (GbProductList: Eyebrow, Titel, Claim + Product[]{Variant,Name,Desc,Link})
    geobonus-stategrid.xsd    (GbStateGrid: Eyebrow, Titel + Tile[]{Name,Status,Link,Note})
    geobonus-references.xsd   (GbReferences: Eyebrow, Titel, Intro + Reference[]{Title,Subtitle,Count,Link})
    geobonus-showcase.xsd     (GbShowcase: Bild, Eyebrow, Titel, Text, CTA)
    geobonus-legal.xsd        (GbLegal: Eyebrow, Titel, Subtitle, Intro + Section[]{Heading,Body})
  formatters/geobonus/
    geobonus-<x>.jsp          (rendert das originale GeoBonus-Markup: .hero/.product-row/.state-pick/.refs-toggle/.std-*/.legal-*)
    <x>.xml                   (NewFormatter-Config: Type m-gb-<x>, Key m/geobonus/<x>, WEAK-Link auf die JSP)
  i18n/
    com.mapexplorer.geobonus.messages_{de,en}   (alle Labels + type.m-gb-*.name/title/formatter)
```

Alle XSD/XML sind `xmllint`-wohlgeformt; JSP-`<cms:formatter>` balanciert.

## Installation (laufende OpenCms-Instanz nötig — Resource-Type-Registrierung geht nicht per WebDAV allein)

### 1. Dateien ins VFS (per WebDAV push, dann publish)
- `schemas/*.xsd`            → `/system/modules/com.mapexplorer/schemas/`
- `formatters/geobonus/*`    → `/system/modules/com.mapexplorer/formatters/geobonus/`
- `i18n/*`                   → `/system/modules/com.mapexplorer/i18n/`
  (Bundle-Ressourcen-Typ: `propertyvfsbundle`, damit `com.mapexplorer.geobonus.messages` aufgelöst wird.)
- Formatter-Config-XML (`hero.xml` …): Ressourcen-Typ muss **`formatter_config`** sein (sonst werden sie nicht als Formatter erkannt).

### 2. Resource-Types im Modul-Manifest registrieren
In das `<resourcetypes>`-Element von `com.mapexplorer/manifest.xml` (IDs müssen **instanzweit eindeutig** sein —
8701–8706 sind nur Vorschläge, vor Import prüfen):

```xml
<type class="org.opencms.file.types.CmsResourceTypeXmlContent" name="m-gb-hero" id="8701">
  <param name="schema">/system/modules/com.mapexplorer/schemas/geobonus-hero.xsd</param>
</type>
<type class="org.opencms.file.types.CmsResourceTypeXmlContent" name="m-gb-productlist" id="8702">
  <param name="schema">/system/modules/com.mapexplorer/schemas/geobonus-productlist.xsd</param>
</type>
<type class="org.opencms.file.types.CmsResourceTypeXmlContent" name="m-gb-stategrid" id="8703">
  <param name="schema">/system/modules/com.mapexplorer/schemas/geobonus-stategrid.xsd</param>
</type>
<type class="org.opencms.file.types.CmsResourceTypeXmlContent" name="m-gb-references" id="8704">
  <param name="schema">/system/modules/com.mapexplorer/schemas/geobonus-references.xsd</param>
</type>
<type class="org.opencms.file.types.CmsResourceTypeXmlContent" name="m-gb-showcase" id="8705">
  <param name="schema">/system/modules/com.mapexplorer/schemas/geobonus-showcase.xsd</param>
</type>
<type class="org.opencms.file.types.CmsResourceTypeXmlContent" name="m-gb-legal" id="8706">
  <param name="schema">/system/modules/com.mapexplorer/schemas/geobonus-legal.xsd</param>
</type>
```

Explorer-Typen (Icons optional; `reference="xmlcontent"` erbt Standard-Verhalten) im `<explorertypes>`-Element:

```xml
<explorertype name="m-gb-hero" key="type.m-gb-hero.name" reference="xmlcontent">
  <newresource creatable="true" order="10" autosetnavigation="false" autosettitle="false" info="type.m-gb-hero.description" key="type.m-gb-hero.title"/>
</explorertype>
<!-- analog für m-gb-productlist / -stategrid / -references / -showcase / -legal -->
```

Nach Manifest-Änderung: Modul re-importieren **oder** Ressourcen-Typen neu laden (OpenCms Neustart / „Publish + reload type config“).

### 3. Formatter aktivieren
Die Configs haben `AutoEnabled=true` → nach Publish sind sie aktiv. Falls die Sitemap-Config eine explizite
Formatter-Freigabe nutzt: in der `.content/.config` des geobonus-Sub-Sites die neuen Formatter/Types freigeben.

### 4. Content bauen & Homepage zusammensetzen
- Neue Inhalte anlegen (Type „GeoBonus Hero“, „…Produktliste“ …), Felder füllen.
- Bilder liegen bereits im VFS: `/system/modules/com.mapexplorer/resources/img/geobonus-homepage/`.
- Elemente in die Container-Page der Homepage (`/de/index.html`) ziehen (Reihenfolge: Hero → Produktliste → …).
- **Dann** Theme umstellen: Property `mercury.theme` auf `/de/index.html` =
  `/system/modules/com.mapexplorer/css/theme-geobonus-homepage.min.css`,
  Property `mercury.extra.js` = `/system/modules/com.mapexplorer/resources/js/geobonus-homepage.js`.
  (Erst wenn der Content steht — sonst Homepage-Regression, siehe STATUS-Doku.)

## Wichtige Hinweise / zu prüfen in der Instanz

- **Value-Zugriff:** Die JSPs nutzen `${value.Feld}` (wie `content-section.jsp`), weil OpenCms das
  `…Data > Einzelkind`-Schema auf die Kind-Felder auspackt. Falls in dieser Instanz nicht: auf
  `${value.GbHero.value.Feld}` umstellen. Vor dem Livegang mit einem Testinhalt verifizieren.
- **WEAK-Link-UUIDs** in den `*.xml` sind generiert; OpenCms löst WEAK-Links beim Import über den
  **Ziel-Pfad** auf — die UUID ist nur ein Hinch. Kein manuelles UUID-Matching nötig.
- **Type-IDs 8701–8706**: vor Import auf Kollision prüfen (`grep 'id="87'` im Instanz-Manifest).
- **shared-settings**: die Configs inkludieren `/system/modules/alkacon.mercury.template/configuration/shared-settings.xml`
  (Setting-Includes `cssWrapper.default`, `cssVisibility.default`). Modul `alkacon.mercury.template` muss vorhanden sein (ist es — Template basiert darauf).
- **Referenzen-Disclosure**: das Aufklapp-JS der Referenzen ist nicht dabei (war ~700 Z. in oesterreich.html);
  der Formatter rendert die `.refs-toggle` als Links. Aufklappen optional später ergänzen.
- **Interaktive Österreich-Karte**: bewusst nicht als Formatter — der Bundesland-Grid (`.state-pick`) deckt das
  im Handover geforderte Auswahlraster ab.

## Verifikation lokal
- `xmllint --noout schemas/*.xsd formatters/geobonus/*.xml` → alle wohlgeformt.
- JSP-Markup entspricht 1:1 den Klassen des Theme-CSS (`theme-geobonus-homepage.min.css`), das bereits publiziert ist.
