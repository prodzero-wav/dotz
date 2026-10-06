#!/usr/bin/env bash
# LABYRINTH Firefox theme (userChrome.css + userContent.css + prefs). Safe to re-run.
set -e
shopt -s nullglob
found=0

for base in "$HOME/.mozilla/firefox" "$HOME/.config/mozilla/firefox"; do
  [ -d "$base" ] || continue
  for p in "$base"/*.default-release "$base"/*.default; do
    [ -d "$p" ] || continue
    found=1
    echo "==> themeing $p"
    mkdir -p "$p/chrome"

    cat > "$p/chrome/userChrome.css" << 'EOF'
/* LABYRINTH */
:root {
  --lab-bg: #060b09;
  --lab-bg2: #0d1814;
  --lab-green: #1f3a31;
  --lab-teal: #6f9f8b;
  --lab-bone: #d4cba8;
  --lab-dim: #8f8a6e;
  --lab-line: rgba(212, 203, 168, 0.25);

  --toolbar-bgcolor: var(--lab-bg2) !important;
  --toolbar-color: var(--lab-bone) !important;
  --toolbar-field-background-color: var(--lab-bg) !important;
  --toolbar-field-color: var(--lab-bone) !important;
  --toolbar-field-focus-background-color: var(--lab-bg) !important;
  --toolbar-field-focus-color: var(--lab-bone) !important;
  --toolbar-field-border-color: var(--lab-line) !important;
  --lwt-accent-color: var(--lab-bg) !important;
  --lwt-text-color: var(--lab-bone) !important;
  --tab-selected-bgcolor: var(--lab-bg2) !important;
  --tab-selected-textcolor: var(--lab-bone) !important;
  --arrowpanel-background: var(--lab-bg) !important;
  --arrowpanel-color: var(--lab-bone) !important;
  --arrowpanel-border-color: var(--lab-teal) !important;
  --autocomplete-popup-background: var(--lab-bg) !important;
  --autocomplete-popup-color: var(--lab-bone) !important;
  --autocomplete-popup-highlight-background: var(--lab-green) !important;
  --autocomplete-popup-highlight-color: var(--lab-bone) !important;
  --sidebar-background-color: var(--lab-bg) !important;
  --sidebar-text-color: var(--lab-bone) !important;
}

/* sharp corners everywhere: maze walls */
* { border-radius: 0 !important; }

#navigator-toolbox {
  background: var(--lab-bg) !important;
  border-bottom: 1px solid var(--lab-line) !important;
}
#nav-bar {
  box-shadow: none !important;
  border-top: none !important;
}

/* url bar glows teal when focused */
#urlbar-background {
  background: var(--lab-bg) !important;
  border: 1px solid var(--lab-line) !important;
  box-shadow: none !important;
}
#urlbar[focused] > #urlbar-background,
#urlbar[open] > #urlbar-background {
  border-color: var(--lab-teal) !important;
  box-shadow: 0 0 14px rgba(111, 159, 139, 0.45) !important;
}

/* tabs */
.tab-background {
  margin-block: 0 !important;
  background: transparent !important;
  box-shadow: none !important;
  outline: none !important;
}
.tab-background[selected] {
  background: var(--lab-bg2) !important;
  box-shadow: inset 0 -2px 0 var(--lab-bone), 0 0 16px rgba(212, 203, 168, 0.18) !important;
}
.tabbrowser-tab:not([selected]) .tab-label { color: var(--lab-dim) !important; }
.tabbrowser-tab:not([selected]):hover .tab-background { background: rgba(212, 203, 168, 0.07) !important; }
.tabbrowser-tab[selected] .tab-label { color: var(--lab-bone) !important; }

/* buttons */
toolbarbutton:hover > .toolbarbutton-icon,
.toolbarbutton-1:hover > .toolbarbutton-icon {
  background: rgba(111, 159, 139, 0.18) !important;
}

/* tiling WM: no window buttons */
.titlebar-buttonbox-container { display: none !important; }

/* menus and panels */
menupopup, panel { --panel-background: var(--lab-bg); --panel-color: var(--lab-bone); --panel-border-color: var(--lab-teal); }
menupopup > menuitem:hover, menupopup > menu:hover { background: var(--lab-green) !important; }

/* kill the purple: Firefox's built-in dark theme colours showing through */
:root {
  --lwt-accent-color-inactive: #060b09 !important;
  --toolbar-non-lwt-bgcolor: #0d1814 !important;
  --toolbar-non-lwt-bgimage: none !important;
  --tabs-border-color: rgba(212, 203, 168, 0.25) !important;
  --lwt-tab-line-color: #d4cba8 !important;
  --urlbar-box-bgcolor: #060b09 !important;
  --urlbar-box-hover-bgcolor: #0d1814 !important;
  --urlbar-box-focus-bgcolor: #060b09 !important;
  --toolbarbutton-icon-fill: #d4cba8 !important;
  --toolbarbutton-hover-background: rgba(111, 159, 139, 0.18) !important;
  --toolbarbutton-active-background: rgba(111, 159, 139, 0.3) !important;
  --focus-outline-color: #6f9f8b !important;
}
#navigator-toolbox, #titlebar, .browser-titlebar, #TabsToolbar,
#TabsToolbar-customization-target, #PersonalToolbar {
  background: #060b09 !important;
  background-image: none !important;
}
#nav-bar { background: #0d1814 !important; background-image: none !important; }
EOF

    cat > "$p/chrome/userContent.css" << 'EOF'
/* LABYRINTH */
@-moz-document url-prefix("about:") {
  :root {
    --newtab-background-color: #060b09 !important;
    --in-content-page-background: #060b09 !important;
    --in-content-page-color: #d4cba8 !important;
    --in-content-box-background: #0d1814 !important;
    --in-content-primary-button-background: #6f9f8b !important;
    --in-content-primary-button-text-color: #060b09 !important;
    --in-content-accent-color: #6f9f8b !important;
  }
}
EOF

    [ -f "$p/user.js" ] && sed -i '/LABYRINTH-BEGIN/,/LABYRINTH-END/d' "$p/user.js"
    cat >> "$p/user.js" << 'EOF'
// LABYRINTH-BEGIN
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
user_pref("browser.uidensity", 1);
user_pref("browser.compactmode.show", true);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
// LABYRINTH-END
EOF
  done
done

if [ "$found" = 0 ]; then
  echo "No Firefox profile found. Open Firefox once, close it, then rerun."
  exit 1
fi
echo "Done. Fully quit Firefox and reopen it."
