class JsInjector {
  static String hideAds() {
    return '''
(function() {
  var css = 'iframe[src*="doubleclick"], iframe[src*="googleads"], ' +
    'iframe[src*="adserver"], iframe[src*="adservice"], ' +
    'iframe[src*="googlesyndication"], iframe[src*="adsafeprotected"], ' +
    '.ad-overlay, .ad-container, .ad-wrapper, ' +
    '[class*="ad-overlay"], [class*="ad-container"], [id*="ad-overlay"], [id*="ad-container"] ' +
    '{ display: none !important; }';
  var style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  function removeAds() {
    var selectors = [
      '.overlay-ad', '.modal-ad', '.pop-ad', '.preroll-ad',
      '[class*="preroll"]', '[class*="midroll"]', '[class*="overlay"][class*="ad"]',
      '.ad-block', '.ad-skip', '.skip-button', '.skip-ad'
    ];
    selectors.forEach(function(sel) {
      try {
        document.querySelectorAll(sel).forEach(function(el) {
          if (el.offsetHeight > 0 || el.offsetWidth > 0) el.remove();
        });
      } catch(e) {}
    });
  }

  removeAds();
  setInterval(removeAds, 3000);
})();
''';
  }

  static String startLanguagePolling(String langCode, String bcp47) {
    if (langCode == 'ORIGINAL') return '(function() { return "original_skipped"; })();';
    
    var searchTerms = [langCode.toLowerCase(), bcp47.toLowerCase()];
    if (langCode.toUpperCase().startsWith('ES')) {
      searchTerms.addAll(['spanish', 'español', 'latino', 'castellano', 'spa']);
    }

    return '''
(function() {
  var searchTerms = ${searchTerms.map((s) => "'$s'").toList()};
  
  function matchTrack(t) {
    if (!t) return false;
    var label = (t.label || t.name || t.id || t.language || t.lang || '').toLowerCase();
    return searchTerms.some(function(term) { return label.indexOf(term) !== -1; });
  }

  function applyToPlayer(win) {
    var found = 0;
    try {
        // 1. Hls.js
        if (win.Hls && win.Hls.instances) {
          win.Hls.instances.forEach(function(hls) {
            for (var i = 0; i < hls.audioTracks.length; i++) {
              if (matchTrack(hls.audioTracks[i])) { 
                if (hls.audioTrack !== i) { hls.audioTrack = i; found++; }
              }
            }
          });
        }
        // 2. JWPlayer
        if (typeof win.jwplayer === 'function') {
          try {
            var jwp = win.jwplayer();
            var tracks = jwp.getAudioTracks();
            for (var i = 0; i < (tracks || []).length; i++) {
              if (matchTrack(tracks[i])) { 
                if (jwp.getCurrentAudioTrack() !== i) { jwp.setCurrentAudioTrack(i); found++; }
              }
            }
          } catch(e) {}
        }
        // 3. VideoJS
        if (typeof win.videojs === 'function') {
          try {
            var players = win.videojs.getPlayers();
            for (var id in players) {
              var p = players[id];
              if (p.audioTracks) {
                var tracks = p.audioTracks();
                for (var i = 0; i < tracks.length; i++) {
                  if (matchTrack(tracks[i])) { 
                    if (!tracks[i].enabled) { tracks[i].enabled = true; found++; }
                  } else { tracks[i].enabled = false; }
                }
              }
            }
          } catch(e) {}
        }
    } catch(e) {}
    return found;
  }

  function scanAll(win) {
    var matched = applyToPlayer(win);
    try {
        var frames = win.document.querySelectorAll('iframe');
        for (var i = 0; i < frames.length; i++) {
          try { matched += scanAll(frames[i].contentWindow); } catch(e) {}
        }
    } catch(e) {}
    return matched;
  }

  var attempts = 0;
  var interval = setInterval(function() {
    attempts++;
    var count = scanAll(window);
    if (count > 0 || attempts > 20) clearInterval(interval);
  }, 1000);
})();
''';
  }

  /// Scans the page for multiple server/source selectors, finds the first
  /// one with a Spanish label ("Latino", "Español", "Castellano", "Spanish",
  /// "ES", etc.), clicks it, and returns the label that was selected.
  /// Returns empty string if no Spanish source is found.
  static String selectSpanishSource() {
    return '''
(function() {
  var spanishKeywords = ['latino', 'español', 'espanol', 'castellano', 'spanish', 'es', 'spa', 'mexico', 'mex'];
  function isSpanish(text) {
    var t = (text || '').toLowerCase().trim();
    if (t === 'es') return true;
    return spanishKeywords.some(function(kw) { return t.indexOf(kw) !== -1; });
  }

  var clicked = '';
  var candidates = [];

  // Phase 1: collect all clickable items that look like server/source selectors
  function collect(el) {
    if (!el || !el.querySelectorAll) return;
    // Buttons & links
    el.querySelectorAll('button, a, [role="button"], .server-item, .source-item, .quality-item, .lang-item').forEach(function(e) {
      var txt = (e.textContent || e.innerText || '').trim();
      var title = (e.title || '').trim();
      var dataLang = (e.getAttribute('data-lang') || e.getAttribute('data-language') || '').trim();
      var cls = (e.className || '').toLowerCase();
      var combined = txt + ' ' + title + ' ' + dataLang + ' ' + cls;
      if (combined.length > 1) candidates.push({el: e, text: combined});
    });
    // Select options
    el.querySelectorAll('select option').forEach(function(o) {
      var txt = (o.textContent || o.innerText || '').trim();
      var val = (o.value || '').trim();
      var combined = txt + ' ' + val;
      if (combined.length > 1) candidates.push({el: o, text: combined, parent: o.closest('select')});
    });
  }
  collect(document);
  document.querySelectorAll('iframe').forEach(function(f) {
    try { collect(f.contentDocument || f.contentWindow.document); } catch(e) {}
  });

  // Phase 2: find Spanish-labeled items
  var spanishItem = null;
  for (var i = 0; i < candidates.length; i++) {
    if (isSpanish(candidates[i].text)) {
      spanishItem = candidates[i];
      clicked = candidates[i].text.substring(0, 80);
      break;
    }
  }

  // Phase 3: click or select it
  if (spanishItem) {
    try {
      if (spanishItem.parent) {
        // Select option — change the parent select
        spanishItem.parent.value = spanishItem.el.value;
        spanishItem.parent.dispatchEvent(new Event('change', {bubbles: true}));
      } else {
        spanishItem.el.click();
        spanishItem.el.dispatchEvent(new MouseEvent('mousedown', {bubbles: true}));
        spanishItem.el.dispatchEvent(new MouseEvent('mouseup', {bubbles: true}));
      }
    } catch(e) {}
  }

  return JSON.stringify({
    clicked: clicked,
    totalCandidates: candidates.length,
    spanishFound: !!spanishItem
  });
})();
''';
  }

  static String extractVideoSource() {
    return '''
(function() {
  function findDeepVideo(win) {
    try {
        var v = win.document.querySelector('video');
        if (v && (v.src || v.querySelector('source'))) return {video: v, win: win};
        
        var frames = win.document.querySelectorAll('iframe');
        for (var i = 0; i < frames.length; i++) {
          try {
            var res = findDeepVideo(frames[i].contentWindow);
            if (res) return res;
          } catch(e) {}
        }
    } catch(e) {}
    return null;
  }

  var res = findDeepVideo(window);
  if (!res) {
    if (window.PlayerBridge) window.PlayerBridge.postMessage(JSON.stringify({hasVideo: false}));
    return JSON.stringify({hasVideo: false});
  }

  var v = res.video;
  var win = res.win;
  var src = v.src;
  if (!src || src.startsWith('blob:')) {
    var s = v.querySelector('source');
    if (s) src = s.src;
  }

  var hlsUrl = '';
  if (win.Hls && win.Hls.instances && win.Hls.instances.length > 0) {
    hlsUrl = win.Hls.instances[0].url || '';
  }

  var result = {
    hasVideo: true,
    src: src || '',
    hlsUrl: hlsUrl,
    headers: {
      "Referer": win.location.href,
      "Origin": win.location.origin,
      "User-Agent": navigator.userAgent
    }
  };

  if (window.PlayerBridge) window.PlayerBridge.postMessage(JSON.stringify(result));
  return JSON.stringify(result);
})();
''';
  }

  static String toggleSubtitles(bool enabled) {
    final mode = enabled ? 'showing' : 'hidden';
    return '''
(function() {
  function apply(win) {
    try {
        win.document.querySelectorAll('video').forEach(function(v) {
          for (var i = 0; i < v.textTracks.length; i++) v.textTracks[i].mode = '$mode';
        });
        win.document.querySelectorAll('iframe').forEach(function(f) {
          try { apply(f.contentWindow); } catch(e) {}
        });
    } catch(e) {}
  }
  apply(window);
  return true;
})();
''';
  }

  static String getSubtitleTracks() {
    return '''
(function() {
  var tracks = [];
  function scan(win) {
    try {
        win.document.querySelectorAll('video').forEach(function(v) {
          for (var i = 0; i < v.textTracks.length; i++) {
            var t = v.textTracks[i];
            tracks.push({
              index: tracks.length,
              label: t.label || t.language || 'Track ' + (tracks.length + 1),
              language: t.language || '',
              kind: t.kind,
              mode: t.mode
            });
          }
        });
        win.document.querySelectorAll('iframe').forEach(function(f) {
          try { scan(f.contentWindow); } catch(e) {}
        });
    } catch(e) {}
  }
  scan(window);
  return JSON.stringify(tracks);
})();
''';
  }

  static String setSubtitleTrack(int index) {
    return '''
(function() {
  var target = $index;
  var current = 0;
  function apply(win) {
    try {
        win.document.querySelectorAll('video').forEach(function(v) {
          for (var i = 0; i < v.textTracks.length; i++) {
            v.textTracks[i].mode = (current === target) ? 'showing' : 'hidden';
            current++;
          }
        });
        win.document.querySelectorAll('iframe').forEach(function(f) {
          try { apply(f.contentWindow); } catch(e) {}
        });
    } catch(e) {}
  }
  apply(window);
  return true;
})();
''';
  }

  static String getQualityLevels() {
    return '''
(function() {
  var levels = [];
  function scan(win) {
    try {
        if (win.Hls && win.Hls.instances) {
          win.Hls.instances.forEach(function(hls) {
            hls.levels.forEach(function(l, i) {
              levels.push({
                index: i,
                label: l.name || (l.height + 'p'),
                height: l.height,
                bitrate: l.bitrate
              });
            });
          });
        }
        win.document.querySelectorAll('iframe').forEach(function(f) {
          try { scan(f.contentWindow); } catch(e) {}
        });
    } catch(e) {}
  }
  scan(window);
  return JSON.stringify(levels);
})();
''';
  }

  static String setQualityLevel(int index) {
    return '''
(function() {
  var target = $index;
  function apply(win) {
    try {
        if (win.Hls && win.Hls.instances) {
          win.Hls.instances.forEach(function(hls) { hls.currentLevel = target; });
        }
        win.document.querySelectorAll('iframe').forEach(function(f) {
          try { apply(f.contentWindow); } catch(e) {}
        });
    } catch(e) {}
  }
  apply(window);
  return true;
})();
''';
  }
}
