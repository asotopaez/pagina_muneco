'use strict';

/* ============================================================
   CONSTANTS
   ============================================================ */
const HEADER_SCROLL_THRESHOLD = 50;
const HEADER_HEIGHT = 72;
const WA_NUMBER = '5215615486432';
const WA_BASE = `https://wa.me/${WA_NUMBER}`;
const WA_MSG = encodeURIComponent('Hola, necesito un cerrajero urgente. ¿Pueden ayudarme?');
const WA_CTA_URL = `${WA_BASE}?text=${WA_MSG}`;

/* ============================================================
   DOM READY
   ============================================================ */
document.addEventListener('DOMContentLoaded', () => {
  initHeaderScroll();
  initMobileMenu();
  initSmoothScroll();
  initActiveNav();
  initAnimations();
  initYear();
  setPrefillLinks();
});

/* ============================================================
   1. HEADER SCROLL EFFECT
   ============================================================ */
function initHeaderScroll() {
  const header = document.getElementById('header');
  if (!header) return;

  let ticking = false;

  window.addEventListener('scroll', () => {
    if (!ticking) {
      requestAnimationFrame(() => {
        if (window.scrollY > HEADER_SCROLL_THRESHOLD) {
          header.classList.add('scrolled');
        } else {
          header.classList.remove('scrolled');
        }
        ticking = false;
      });
      ticking = true;
    }
  }, { passive: true });
}

/* ============================================================
   2. MOBILE MENU
   ============================================================ */
function initMobileMenu() {
  const btn = document.getElementById('hamburger-btn');
  const menu = document.getElementById('nav-menu');
  if (!btn || !menu) return;

  function openMenu() {
    menu.classList.add('is-open');
    btn.classList.add('is-active');
    btn.setAttribute('aria-expanded', 'true');
    document.body.classList.add('no-scroll');
  }

  function closeMenu() {
    menu.classList.remove('is-open');
    btn.classList.remove('is-active');
    btn.setAttribute('aria-expanded', 'false');
    document.body.classList.remove('no-scroll');
  }

  function toggleMenu() {
    if (menu.classList.contains('is-open')) {
      closeMenu();
    } else {
      openMenu();
    }
  }

  btn.addEventListener('click', toggleMenu);

  // Close on nav link click
  menu.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', closeMenu);
  });

  // Close on outside click
  document.addEventListener('click', (e) => {
    if (
      menu.classList.contains('is-open') &&
      !menu.contains(e.target) &&
      !btn.contains(e.target)
    ) {
      closeMenu();
    }
  });

  // Close on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && menu.classList.contains('is-open')) {
      closeMenu();
      btn.focus();
    }
  });
}

/* ============================================================
   3. SMOOTH SCROLL (with offset for fixed header)
   ============================================================ */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      const targetId = anchor.getAttribute('href');
      if (!targetId || targetId === '#') return;

      const target = document.querySelector(targetId);
      if (!target) return;

      e.preventDefault();

      const targetTop = target.getBoundingClientRect().top + window.scrollY - HEADER_HEIGHT;

      window.scrollTo({
        top: targetTop,
        behavior: 'smooth'
      });
    });
  });
}

/* ============================================================
   4. ACTIVE NAV HIGHLIGHT (IntersectionObserver)
   ============================================================ */
function initActiveNav() {
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('#nav-menu a[href^="#"]');
  if (!sections.length || !navLinks.length) return;

  const observerOptions = {
    root: null,
    rootMargin: `-${HEADER_HEIGHT}px 0px -40% 0px`,
    threshold: 0
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.getAttribute('id');
        navLinks.forEach(link => {
          link.classList.remove('active');
          if (link.getAttribute('href') === `#${id}`) {
            link.classList.add('active');
          }
        });
      }
    });
  }, observerOptions);

  sections.forEach(section => observer.observe(section));
}

/* ============================================================
   5. ENTRANCE ANIMATIONS (IntersectionObserver)
   ============================================================ */
function initAnimations() {
  const elements = document.querySelectorAll('.animate-on-scroll');
  if (!elements.length) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, {
    root: null,
    rootMargin: '0px 0px -60px 0px',
    threshold: 0.1
  });

  elements.forEach(el => observer.observe(el));
}

/* ============================================================
   6. FOOTER YEAR
   ============================================================ */
function initYear() {
  const el = document.getElementById('year');
  if (el) el.textContent = new Date().getFullYear();
}

/* ============================================================
   7. SET PRE-FILLED WA LINKS
   ============================================================ */
function setPrefillLinks() {
  // Set the pre-filled WA URL on all CTA WA links (not the float button)
  document.querySelectorAll('[data-wa-cta]').forEach(el => {
    el.setAttribute('href', WA_CTA_URL);
  });

  // Float button stays as base URL
  const floatBtn = document.querySelector('.float-wa');
  if (floatBtn) {
    floatBtn.setAttribute('href', WA_BASE);
  }
}
