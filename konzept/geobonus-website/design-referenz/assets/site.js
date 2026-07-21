/* ============================================================
   GeoBonus — shared chrome behaviour
   Header scroll state, mobile nav, scroll reveal, copyright year,
   and the "Projekt anfragen" modal.

   Mirrors the inline scripts in index.html / oesterreich.html.
   ============================================================ */
(function(){
  'use strict';

  document.documentElement.classList.add('js');

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---- Header scroll state ----
     Pages without a dark hero pin the header solid via .site-header--solid and
     opt out of the scroll toggle entirely. */
  var header = document.getElementById('siteHeader');
  if (header && !header.classList.contains('site-header--solid')) {
    var onScroll = function(){
      if (window.scrollY > 8) header.classList.add('scrolled');
      else header.classList.remove('scrolled');
    };
    document.addEventListener('scroll', onScroll, { passive:true });
    onScroll();
  }

  /* ---- Mobile nav ---- */
  var toggle = document.getElementById('menuToggle');
  var panel = document.getElementById('mobilePanel');
  if (toggle && panel) {
    toggle.addEventListener('click', function(){
      var open = panel.classList.toggle('open');
      toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      toggle.setAttribute('aria-label', open ? 'Menü schließen' : 'Menü öffnen');
    });
    panel.querySelectorAll('a').forEach(function(a){
      a.addEventListener('click', function(){
        panel.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.setAttribute('aria-label', 'Menü öffnen');
      });
    });
    document.addEventListener('keydown', function(e){
      if (e.key === 'Escape' && panel.classList.contains('open')) {
        panel.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
        toggle.focus();
      }
    });
  }

  /* ---- Copyright year ---- */
  var copyYearEl = document.getElementById('copyYear');
  if (copyYearEl) copyYearEl.textContent = new Date().getFullYear();

  /* ---- Scroll reveal ---- */
  var revealEls = document.querySelectorAll('[data-reveal]');
  if (reduceMotion || !('IntersectionObserver' in window)) {
    revealEls.forEach(function(el){ el.classList.add('in-view'); });
  } else {
    var obs = new IntersectionObserver(function(entries){
      entries.forEach(function(entry){
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          obs.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -8% 0px' });
    revealEls.forEach(function(el){ obs.observe(el); });
  }

  /* ---- Project inquiry modal ---- */
  var overlay = document.getElementById('projectModalOverlay');
  if (!overlay) return;

  var modalClose = document.getElementById('modalClose');
  var formWrap = document.getElementById('modalFormWrap');
  var successView = document.getElementById('modalSuccess');
  var form = document.getElementById('projectForm');
  var lastFocused = null;

  function openModal(){
    lastFocused = document.activeElement;
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
    var firstInput = document.getElementById('pf-name');
    if (firstInput) setTimeout(function(){ firstInput.focus(); }, 250);
  }
  function closeModal(){
    overlay.classList.remove('open');
    document.body.style.overflow = '';
    if (lastFocused) lastFocused.focus();
  }

  document.querySelectorAll('[data-action="projekt"]').forEach(function(el){
    el.addEventListener('click', function(e){
      e.preventDefault();
      if (panel) panel.classList.remove('open');
      openModal();
    });
  });
  if (modalClose) modalClose.addEventListener('click', closeModal);
  overlay.addEventListener('click', function(e){ if (e.target === overlay) closeModal(); });
  document.addEventListener('keydown', function(e){
    if (e.key === 'Escape' && overlay.classList.contains('open')) closeModal();
  });

  var interestGemeinde = document.getElementById('interestGemeinde');
  var interestBetrieb = document.getElementById('interestBetrieb');
  var orgLabel = document.getElementById('pf-org-label');
  function syncType(){
    var checked = document.querySelector('input[name="type"]:checked');
    if (!checked) return;
    var val = checked.value;
    if (interestGemeinde) interestGemeinde.hidden = val !== 'gemeinde';
    if (interestBetrieb) interestBetrieb.hidden = val !== 'betrieb';
    if (orgLabel) orgLabel.textContent = val === 'gemeinde' ? 'Gemeinde' : 'Firmenname';
  }
  document.querySelectorAll('input[name="type"]').forEach(function(r){ r.addEventListener('change', syncType); });
  syncType();

  if (form) {
    form.addEventListener('submit', function(e){
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
