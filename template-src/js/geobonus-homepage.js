/*
 * GeoBonus Homepage — chrome behaviour
 * Ported from konzept/geobonus-website/design-referenz/ (site.js + index.html inline JS).
 *
 * Standalone IIFE — deliberately NOT wired into mercury.js so it stays isolated to the
 * GeoBonus homepage theme. Load it once per page (see STATUS-geobonus-homepage.md):
 *   <script src="/system/modules/alkacon.mercury.theme/js/geobonus-homepage.js" defer></script>
 *
 * Covers: page loader, header scroll state, mobile nav, hero mouse-parallax,
 * scroll reveal ([data-reveal] / [data-reveal-stagger]), copyright year, and the
 * "Projekt anfragen" modal (Gemeinde/Betrieb toggle + mailto submit).
 */
(function () {
  'use strict';

  document.documentElement.classList.add('js');

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---- Sync mobile panel nav from the (CMS-rendered) desktop nav ----
     The desktop .nav-group may be filled by the GeoBonus navigation formatter.
     Clone its links into #mobilePanel (before the CTA button) so mobile matches. */
  (function () {
    var group = document.querySelector('.nav-group');
    var mpanel = document.getElementById('mobilePanel');
    if (!group || !mpanel) return;
    var links = group.querySelectorAll('.nav-link');
    if (!links.length) return;
    mpanel.querySelectorAll('.nav-link').forEach(function (a) { a.remove(); });
    var firstBtn = mpanel.querySelector('.btn');
    links.forEach(function (a) {
      var c = a.cloneNode(true);
      c.removeAttribute('aria-current');
      mpanel.insertBefore(c, firstBtn || null);
    });
  })();

  /* ---- Page loader (only present on the homepage) ---- */
  (function () {
    var loader = document.getElementById('pageLoader');
    var html = document.documentElement;
    if (!loader) { html.classList.remove('is-loading'); return; }

    var MIN_MS = reduceMotion ? 200 : 1100;
    var MAX_MS = 2200;
    var start = Date.now();
    var done = false;

    function reveal() {
      if (done) return;
      done = true;
      html.classList.remove('is-loading');
      loader.classList.add('is-hidden');
      loader.setAttribute('aria-hidden', 'true');
      window.setTimeout(function () {
        if (loader.parentNode) loader.parentNode.removeChild(loader);
      }, 700);
    }
    function ready() {
      var elapsed = Date.now() - start;
      window.setTimeout(reveal, Math.max(MIN_MS - elapsed, 0));
    }
    if (document.readyState === 'complete') ready();
    else window.addEventListener('load', ready);
    window.setTimeout(reveal, MAX_MS);
  })();

  /* ---- Header scroll state ----
     Pages that pin the header solid opt out via .site-header--solid. */
  var header = document.getElementById('siteHeader');
  if (header && !header.classList.contains('site-header--solid')) {
    var onScroll = function () {
      if (window.scrollY > 8) header.classList.add('scrolled');
      else header.classList.remove('scrolled');
    };
    document.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* ---- Mobile nav ---- */
  var toggle = document.getElementById('menuToggle');
  var panel = document.getElementById('mobilePanel');
  if (toggle && panel) {
    toggle.addEventListener('click', function () {
      var open = panel.classList.toggle('open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      toggle.setAttribute('aria-label', open ? 'Menü schließen' : 'Menü öffnen');
    });
    panel.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () {
        panel.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.setAttribute('aria-label', 'Menü öffnen');
      });
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && panel.classList.contains('open')) {
        panel.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.focus();
      }
    });
  }

  /* ---- Hero mouse-parallax (subtle; paused when hero off-screen) ---- */
  var heroBg = document.getElementById('heroBg');
  var heroSection = document.querySelector('.hero');
  if (heroBg && heroSection && !reduceMotion && window.matchMedia('(hover: hover)').matches) {
    var tx = 0, ty = 0, cx = 0, cy = 0, rafId = null, heroVisible = true;
    window.addEventListener('mousemove', function (e) {
      if (!heroVisible) return;
      tx = ((e.clientX / window.innerWidth) - 0.5) * 16;
      ty = ((e.clientY / window.innerHeight) - 0.5) * 12;
    }, { passive: true });
    function raf() {
      cx += (tx - cx) * 0.045;
      cy += (ty - cy) * 0.045;
      heroBg.style.transform = 'translate(' + cx.toFixed(2) + 'px,' + cy.toFixed(2) + 'px)';
      rafId = requestAnimationFrame(raf);
    }
    function startRaf() { if (rafId === null) rafId = requestAnimationFrame(raf); }
    function stopRaf() { if (rafId !== null) { cancelAnimationFrame(rafId); rafId = null; } }
    if ('IntersectionObserver' in window) {
      new IntersectionObserver(function (entries) {
        heroVisible = entries[0].isIntersecting;
        if (heroVisible) startRaf(); else stopRaf();
      }, { threshold: 0 }).observe(heroSection);
    }
    startRaf();
  }

  /* ---- Copyright year ---- */
  var copyYearEl = document.getElementById('copyYear');
  if (copyYearEl) copyYearEl.textContent = new Date().getFullYear();

  /* ---- Scroll reveal ([data-reveal] + [data-reveal-stagger]) ---- */
  var revealEls = document.querySelectorAll('[data-reveal], [data-reveal-stagger]');
  if (reduceMotion || !('IntersectionObserver' in window)) {
    revealEls.forEach(function (el) { el.classList.add('in-view'); });
  } else {
    var obs = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          obs.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -8% 0px' });
    revealEls.forEach(function (el) { obs.observe(el); });
  }

  /* ---- Project inquiry modal ---- */
  var overlay = document.getElementById('projectModalOverlay');
  if (!overlay) return;

  var modalClose = document.getElementById('modalClose');
  var formWrap = document.getElementById('modalFormWrap');
  var successView = document.getElementById('modalSuccess');
  var form = document.getElementById('projectForm');
  var lastFocused = null;

  function openModal() {
    lastFocused = document.activeElement;
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
    var firstInput = document.getElementById('pf-name');
    if (firstInput) setTimeout(function () { firstInput.focus(); }, 250);
  }
  function closeModal() {
    overlay.classList.remove('open');
    document.body.style.overflow = '';
    if (lastFocused) lastFocused.focus();
  }

  document.querySelectorAll('[data-action="projekt"]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      e.preventDefault();
      if (panel) panel.classList.remove('open');
      openModal();
    });
  });
  if (modalClose) modalClose.addEventListener('click', closeModal);
  overlay.addEventListener('click', function (e) { if (e.target === overlay) closeModal(); });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && overlay.classList.contains('open')) closeModal();
  });

  var interestGemeinde = document.getElementById('interestGemeinde');
  var interestBetrieb = document.getElementById('interestBetrieb');
  var orgLabel = document.getElementById('pf-org-label');
  function syncType() {
    var checked = document.querySelector('input[name="type"]:checked');
    if (!checked) return;
    var val = checked.value;
    if (interestGemeinde) interestGemeinde.hidden = val !== 'gemeinde';
    if (interestBetrieb) interestBetrieb.hidden = val !== 'betrieb';
    if (orgLabel) orgLabel.textContent = val === 'gemeinde' ? 'Gemeinde' : 'Firmenname';
  }
  document.querySelectorAll('input[name="type"]').forEach(function (r) { r.addEventListener('change', syncType); });
  syncType();

  if (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var data = new FormData(form);
      var type = data.get('type');
      var lines = [];
      lines.push('Name: ' + (data.get('name') || ''));
      lines.push('E-Mail: ' + (data.get('email') || ''));
      lines.push('Telefon: ' + (data.get('telefon') || '–'));
      if (data.get('organisation')) lines.push((type === 'gemeinde' ? 'Gemeinde' : 'Firmenname') + ': ' + data.get('organisation'));
      lines.push('Interessiert als: ' + (type === 'gemeinde' ? 'Gemeinde' : 'Betrieb'));
      if (type === 'gemeinde') {
        var interessen = data.getAll('interesse');
        lines.push('Interessensbereiche: ' + (interessen.length ? interessen.join(', ') : '–'));
      } else {
        lines.push('Interessensbereich: ' + (data.get('betrieb_interesse') || '–'));
      }
      var nachricht = data.get('nachricht');
      if (nachricht) { lines.push(''); lines.push('Nachricht:'); lines.push(nachricht); }

      var subject = 'Projektanfrage – ' + (type === 'gemeinde' ? 'Gemeinde' : 'Betrieb');
      var mailto = 'mailto:info@geobonus.at?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(lines.join('\n'));

      formWrap.style.display = 'none';
      successView.classList.add('show');
      window.location.href = mailto;
    });
  }
})();
