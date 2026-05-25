# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

OpenCms Mercury Template — full-featured, modular template for [OpenCms](https://opencms.org), based on Bootstrap 5. Ships Java backend code, JSP/XML formatters, SCSS themes, JavaScript plugins, and OpenCms module manifests.

## Repository layout

The repo is a multi-module OpenCms project. Each top-level `alkacon.mercury.*` directory is one OpenCms module:

- `alkacon.mercury.template` — main module. Java sources under `src/alkacon/mercury/template/...`, JUnit tests under `test/`, OpenCms VFS resources (JSPs, formatters, schemas, element templates, i18n, configuration) under `resources/system/modules/alkacon.mercury.template/`.
- `alkacon.mercury.theme` — static assets (CSS, JS, fonts, images). Output target of the npm build.
- `alkacon.mercury.template.democontents`, `alkacon.mercury.template.jsondemo` — demo content modules.
- `alkacon.mercury.variant.burger`, `alkacon.mercury.webform`, `alkacon.mercury.xtensions` — optional feature modules.
- `template-src/` — source for the static assets that get built into `alkacon.mercury.theme`.
  - `template-src/scss/` — SCSS partials. `themes/theme-*.scss` are the entry points; one minified CSS per theme is generated. `_imports*.scss` wire Bootstrap, fonts, variables.
  - `template-src/js/` — JS sources. `mercury.js` is the webpack entry; other files are bundled or loaded on demand.
  - `template-src/bootstrap5/`, `template-src/fork-awesome/`, `template-src/plugins/` — vendored deps used by the SCSS build.
- `npm_scripts/` — webpack, postcss, cleancss, and vite-env configs invoked by `package.json` scripts.
- `test/` — OpenCms test webapp scaffold (config, HSQLDB, Solr, setupdata) used by the JUnit tests in each module.
- `build/npm/` — generated output. `1_processed/` (sass), `2_postcssed/` (autoprefixed), `3_minified/` (final CSS), `js/` (webpack bundles).

`module-export.conf` lists the modules to export when round-tripping through an OpenCms instance.

## Build commands

### npm (CSS + JS for the theme module)

```shell
npm install              # one-time
npm run dist             # full build: CSS + JS → build/npm/3_minified/ and build/npm/js/
npm run css              # CSS only (sass → postcss → cleancss for every theme-*.scss)
npm run js               # JS only (webpack with mercury.js entry)
npm run watch            # watch SCSS + JS, rebuild on change
npm run vite-proxy       # vite dev server (port 8099) proxying an OpenCms instance for HMR
```

Set `OCMOUNT` (env) to a path that maps to the OpenCms VFS so the `cssg:deploy` / `js:deploy` steps copy the built assets directly into `${OCMOUNT}/system/modules/alkacon.mercury.theme/css|js/` (target dir from `package.json` `config.templateThemeVfsDir`).

Vite mode reads env vars (or `./vite.env.js`): `OPENCMS_SERVER` and `OPENCMS_VITE_SECRET` are required; `OPENCMS_WORKSPACE`, `OPENCMS_SITE`, `OPENCMS_MERCURY_SCSS`, `OPENCMS_MERCURY_JS`, `OPENCMS_VITE_ROOT`, `OPENCMS_REPOSITORIES`, etc. tune resolution. The dev server proxies to the real OpenCms backend and serves only `/scss/`, `/@vite`, `/@fs`, and the configured repo/custom prefixes locally.

### Gradle (OpenCms modules + Java JARs + tests)

```shell
./gradlew bindist                              # build all module ZIPs
./gradlew dist_alkacon.mercury.template        # build a single module distribution
./gradlew jar_alkacon.mercury.template         # build only the module JAR
./gradlew test                                 # run all JUnit tests
./gradlew :alkacon.mercury.template:test --tests TestCmsJspBootstrapBean   # single test
```

Build uses the `org.opencms:opencms-gradle-plugin:3.+`. JARs sitting in any `lib*/` folder (e.g. `alkacon.mercury.template/lib/{cssparser,sac}.jar`) are added to module deps automatically. `gradle.properties` pins `opencms_version=master`.

## Architecture notes

- **Two parallel build systems.** Gradle handles Java compilation, JUnit, and OpenCms module packaging. npm/Vite/Webpack handle the static frontend assets that live in `alkacon.mercury.theme`. They do not invoke each other — running `bindist` does not rebuild CSS/JS, and `npm run dist` does not touch Java. Rebuild whichever side you changed.
- **CSS is theme-multiplexed.** Every `template-src/scss/themes/theme-*.scss` produces one self-contained minified bundle. To add a theme, drop a new `theme-foo.scss` file that overrides variables like `$main-theme`, `$main-theme-hover`, `$main-theme-additional` (or anything from the imported partials) — the npm pipeline picks it up automatically.
- **JS bundles around `mercury.js`.** Webpack entry is `template-src/js/mercury.js`. Splits async chunks (see `npm_scripts/webpack.config.js`); `tinycolor2` is its own named chunk. jQuery is injected as a global via `ProvidePlugin` for Bootstrap, Shariff, etc. Production mode + source maps always on.
- **Java modules follow OpenCms layout.** Java sources live in `<module>/src/`, tests in `<module>/test/`, and the OpenCms VFS payload under `<module>/resources/system/modules/<module>/...` (formatters, schemas, templates, element configurations, JSPs, i18n bundles, etc.). The `alkacon.mercury.template` module's packages are declared in `module.properties`.
- **JSP/formatter content is the main runtime surface.** Most user-visible behaviour lives in the formatter JSPs and XSD schemas under `alkacon.mercury.template/resources/system/modules/alkacon.mercury.template/{formatters,schemas,elements,templates}/`, not in Java. Java classes (under `alkacon.mercury.template.{mail,captcha,writer,subscriptionmanagement,...}`) are helper backends called from JSPs or wired via OpenCms config.
- **Tests need the OpenCms test webapp.** `test/` provides the webapp scaffold (HSQLDB config, Solr config, setupdata, imports). Run tests via Gradle so the plugin sets up classpath and webroot correctly; do not try to run the JUnit classes standalone from an IDE without that setup.

## License

AGPL-3.0. See `README.md` for license header expectations on new source files.
