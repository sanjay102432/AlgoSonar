/**
 * AlgoSonar™ Privacy Policy — script.js
 * Handles: TOC generation, active section highlighting,
 *          scroll animations, back-to-top button, last-updated date.
 */

document.addEventListener('DOMContentLoaded', () => {

  /* ── Last Updated Date ── */
  const lastUpdatedEl = document.getElementById('lastUpdated');
  if (lastUpdatedEl) {
    lastUpdatedEl.textContent = 'March 2, 2026';
  }

  /* ── Build Table of Contents ── */
  const sections = document.querySelectorAll('.policy-section');
  const tocList  = document.getElementById('tocList');

  const tocLabels = {
    s1:  'Introduction',
    s2:  'Information We Collect',
    s3:  'How We Use It',
    s4:  'How We Share It',
    s5:  'Data Retention',
    s6:  'Data Security',
    s7:  'Your Rights',
    s8:  'Cookies & Tracking',
    s9:  "Children's Privacy",
    s10: 'Policy Changes',
    s11: 'Contact Us',
  };

  sections.forEach(section => {
    const id    = section.id;
    const label = tocLabels[id] || section.querySelector('h2')?.textContent.trim() || id;
    const li    = document.createElement('li');
    const a     = document.createElement('a');
    a.href        = `#${id}`;
    a.textContent = label;
    a.dataset.target = id;
    li.appendChild(a);
    if (tocList) tocList.appendChild(li);
  });

  /* ── Intersection Observer: Section Animations + TOC Highlight ── */
  const tocLinks = document.querySelectorAll('#tocList a');

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        /* Fade-in animation */
        entry.target.classList.add('visible');

        /* Highlight active TOC link */
        tocLinks.forEach(link => {
          link.classList.toggle('active', link.dataset.target === entry.target.id);
        });
      }
    });
  }, { threshold: 0.15, rootMargin: '-80px 0px -20% 0px' });

  sections.forEach(s => observer.observe(s));

  /* ── Smooth TOC Scroll ── */
  tocLinks.forEach(link => {
    link.addEventListener('click', e => {
      e.preventDefault();
      const target = document.getElementById(link.dataset.target);
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  /* ── Back to Top Button ── */
  const backToTopBtn = document.getElementById('backToTop');

  window.addEventListener('scroll', () => {
    if (backToTopBtn) {
      backToTopBtn.classList.toggle('visible', window.scrollY > 400);
    }
  });

  if (backToTopBtn) {
    backToTopBtn.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  }

  /* ── Keyboard Accessibility: TOC Skip ── */
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape') {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }
  });
});
