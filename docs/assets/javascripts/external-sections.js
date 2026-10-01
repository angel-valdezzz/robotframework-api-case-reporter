document.querySelectorAll('a[href]').forEach(link => {
  const url = new URL(link.href, location.href);
  if (url.origin === location.origin && /\/(keywords|examples)\//.test(url.pathname)) {
    link.target = '_blank';
    link.rel = 'noopener noreferrer';
    link.title = (link.title ? link.title + ' · ' : '') + 'Abre en una pestaña nueva';
    const hint = document.createElement('span');
    hint.className = 'new-tab-hint';
    hint.textContent = ' ↗';
    hint.setAttribute('aria-label', 'Abre en una pestaña nueva');
    link.append(hint);
  }
});
