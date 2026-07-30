#!/usr/bin/env bash
#
# vet-repo.sh — screen a GitHub repository before trusting it.
#
# Checks the signals that caught two malware-distribution repos posing as
# open-source AI video tools (see SECURITY-AUDIT.md).
#
# Usage:  ./vet-repo.sh owner/repo
#
# This is a triage tool, not a guarantee. It flags patterns worth a human
# look. A clean result means "nothing obvious" — it does not mean "safe".
# It only reads public metadata and never downloads or executes anything.

set -uo pipefail

REPO="${1:-}"
if [[ -z "$REPO" || "$REPO" != */* ]]; then
  echo "Usage: $0 owner/repo" >&2
  exit 2
fi

R=$'\e[31m'; Y=$'\e[33m'; G=$'\e[32m'; B=$'\e[1m'; N=$'\e[0m'
if [[ ! -t 1 ]]; then R=""; Y=""; G=""; B=""; N=""; fi

FLAGS=0; WARNS=0
flag() { echo "  ${R}✗ CRITICAL${N}  $*"; FLAGS=$((FLAGS+1)); }
warn() { echo "  ${Y}! WARNING ${N}  $*"; WARNS=$((WARNS+1)); }
ok()   { echo "  ${G}✓ OK      ${N}  $*"; }
info() { echo "  ${B}i${N}          $*"; }

GET() { curl -sL --max-time 25 "$@"; }

echo
echo "${B}Vetting github.com/$REPO${N}"
echo "────────────────────────────────────────────────────────────"

# ---------------------------------------------------------------- existence
META=$(GET "https://api.github.com/search/repositories?q=repo:${REPO}")
API_OK=1
COUNT=""

if printf '%s' "$META" | grep -q '"total_count"'; then
  COUNT=$(printf '%s' "$META" | grep -o '"total_count"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*$')
else
  # The API did not answer the question we asked — rate limit, auth wall, or a
  # restrictive proxy. That is NOT evidence the repo is missing, so fall back to
  # raw.githubusercontent, which is usually reachable when the API is not.
  API_OK=0
fi

if (( API_OK )) && [[ "${COUNT:-0}" == "0" ]]; then
  echo
  flag "Repository does not exist. A recommendation naming it is unreliable."
  echo
  exit 1
fi

if (( ! API_OK )); then
  echo
  # Environmental, not a property of the repo — reported but not counted as a finding.
  echo "  ${Y}! NOTE     ${N}  GitHub API unavailable (rate limit, auth, or proxy). Metadata checks skipped."
  EXISTS=0
  for br in main master; do
    for f in README.md README.rst README; do
      if [[ "$(curl -sL -o /dev/null -w '%{http_code}' --max-time 15 \
           "https://raw.githubusercontent.com/${REPO}/${br}/${f}")" == "200" ]]; then
        EXISTS=1; break 2
      fi
    done
  done
  if (( EXISTS )); then
    info "Repository is reachable via raw.githubusercontent. Continuing with content checks."
  else
    warn "Could not reach the repository by any route. Verify the name manually before trusting it."
  fi
fi

field() { printf '%s' "$META" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[0-9]*" | head -1 | grep -o '[0-9]*$'; }
sfield() { printf '%s' "$META" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*: *"//; s/"$//'; }

BRANCH=main
if (( API_OK )); then
  STARS=$(field stargazers_count); FORKS=$(field forks_count)
  LANG=$(sfield language); CREATED=$(sfield created_at); BRANCH=$(sfield default_branch)
  STARS=${STARS:-0}; FORKS=${FORKS:-0}; BRANCH=${BRANCH:-main}

  echo
  echo "${B}Metadata${N}"
  info "language: ${LANG:-none}   stars: $STARS   forks: $FORKS"
  info "created: ${CREATED:-?}   default branch: $BRANCH"

  # ---------------------------------------------------------- star:fork ratio
  echo
  echo "${B}Adoption signals${N}"
  if (( STARS >= 50 && FORKS == 0 )); then
    flag "$STARS stars but ZERO forks. Real tools get forked; stars can be bought."
  elif (( STARS >= 100 && FORKS > 0 )) && (( STARS / FORKS > 60 )); then
    warn "Star:fork ratio ${STARS}:${FORKS} is unusually lopsided. Possible inflated stars."
  elif (( STARS > 0 && FORKS > 0 )); then
    ok "Star:fork ratio ${STARS}:${FORKS} looks organic."
  else
    info "Too few signals to judge adoption."
  fi

  # ------------------------------------------------------------------ age
  if [[ -n "$CREATED" ]]; then
    C_EPOCH=$(date -d "$CREATED" +%s 2>/dev/null || echo 0)
    if [[ "$C_EPOCH" != "0" ]]; then
      AGE=$(( ( $(date +%s) - C_EPOCH ) / 86400 ))
      if (( AGE < 90 && STARS > 100 )); then
        warn "${STARS} stars in ${AGE} days. Rapid accumulation on a new repo is a common purchase pattern."
      else
        info "Repository age: ${AGE} days."
      fi
    fi
  fi
fi

# ------------------------------------------------------------------ license
echo
echo "${B}License${N}"
LIC_FOUND=""
for f in LICENSE LICENSE.md LICENSE.txt COPYING; do
  for br in "$BRANCH" main master; do
    if [[ "$(curl -sL -o /dev/null -w '%{http_code}' --max-time 15 \
         "https://raw.githubusercontent.com/${REPO}/${br}/${f}")" == "200" ]]; then
      LIC_FOUND="$f ($br)"; break 2
    fi
  done
done

README=$(GET "https://raw.githubusercontent.com/${REPO}/${BRANCH}/README.md")
[[ -z "$README" || "$README" == "404: Not Found" ]] && README=$(GET "https://raw.githubusercontent.com/${REPO}/main/README.md")

if [[ -n "$LIC_FOUND" ]]; then
  ok "License file present: $LIC_FOUND"
elif printf '%s' "$README" | grep -qiE '\b(MIT|Apache|BSD|GPL)\b.{0,20}[Ll]icense'; then
  warn "README claims a license but NO license file exists. A README is not a grant of rights."
else
  warn "No license file and no license claim. Default copyright reserves all rights."
fi

# --------------------------------------------------------------- obfuscation
echo
echo "${B}Content integrity${N}"
INDEX=$(GET "https://raw.githubusercontent.com/${REPO}/${BRANCH}/index.html")
if [[ -n "$INDEX" && "$INDEX" != "404: Not Found" ]]; then
  if printf '%s' "$INDEX" | grep -qE 'atob\(|eval\(|unescape\(|fromCharCode|document\.write\('; then
    flag "index.html contains obfuscated/dynamic JavaScript (atob/eval/document.write)."
    flag "No legitimate project hides its own landing page. Treat as hostile."
  else
    ok "index.html present with no obfuscation markers."
  fi
fi

# ------------------------------------------------------- code vs marketing
TREE=$(GET "https://api.github.com/repos/${REPO}/git/trees/${BRANCH}?recursive=1")
if printf '%s' "$TREE" | grep -q '"path"'; then
  PATHS=$(printf '%s' "$TREE" | grep -o '"path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//; s/"$//')
  NCODE=$(printf '%s\n' "$PATHS" | grep -cEi '\.(py|js|ts|tsx|jsx|go|rs|rb|java|c|cpp|sh|php)$' || true)
  NTOTAL=$(printf '%s\n' "$PATHS" | grep -c . || true)
  info "${NTOTAL} files tracked, ${NCODE} source files."
  if (( NCODE == 0 )); then
    flag "ZERO source files. A tool with no code is not a tool."
  elif (( NCODE < 3 )); then
    warn "Only ${NCODE} source file(s) — thin for a project claiming to be an application."
  else
    ok "Contains ${NCODE} source files."
  fi
  if printf '%s\n' "$PATHS" | grep -qEi '\.(exe|msi|dmg|scr|bat|jar)$'; then
    flag "Repository ships prebuilt binaries/installers. Verify provenance before running."
  fi
else
  info "File tree unavailable (private, rate-limited, or proxied) — inspect manually."
fi

# ------------------------------------------------------- README behaviour
if [[ -n "$README" && "$README" != "404: Not Found" ]]; then
  echo
  echo "${B}README behaviour${N}"
  if printf '%s' "$README" | grep -qiE '\[.{0,30}(download|get it now|install now).{0,30}\][[:space:]]*\(https?://'; then
    warn "README pushes a Download link. Open source is distributed by cloning, not downloading."
  fi
  # Anchored to archive/AV phrasing only. An earlier revision also matched a bare
  # "password...:..." which fired on Postgres URLs like PASSWORD@localhost:5432 in
  # legitimate setup docs — a scanner that cries wolf gets ignored.
  if printf '%s' "$README" | grep -qiE 'disable (your )?(antivirus|windows defender)|add[^.]{0,20}(defender|antivirus)[^.]{0,20}exclusion|(archive|zip|rar|7z|unzip|extraction) password|password (for|to) (the )?(archive|zip|rar|file)'; then
    flag "README asks users to disable antivirus or supplies an archive password. Hallmark of malware."
  fi
  NAME="${REPO#*/}"
  # Only the first heading in the README's opening lines is a title. Headings deeper in
  # the body are section headers ("Install dependencies") and comparing those to the repo
  # name produced false mismatches on legitimate projects.
  H1=$(printf '%s\n' "$README" \
       | awk 'BEGIN{f=0} /^```/{f=!f; next} !f{print}' \
       | grep -m1 -n '^# ' | awk -F: '$1<=15{sub(/^[0-9]+:/,""); print}' \
       | sed 's/^# *//' | tr -d '*_`')
  # A real project title is short; a sentence is a section heading.
  if [[ $(printf '%s' "${H1%%:*}" | wc -w) -gt 5 ]]; then H1=""; fi
  if [[ -n "$H1" ]]; then
    SLUG=$(printf '%s' "$NAME"   | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    HSLUG=$(printf '%s' "${H1%%:*}" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    if [[ -n "$HSLUG" ]] && ! printf '%s' "$SLUG" | grep -q "$HSLUG" \
       && ! printf '%s' "$HSLUG" | grep -q "$SLUG"; then
      warn "README titles the project \"${H1%%:*}\" but the repo is \"$NAME\". Name mismatch suggests templated spam."
    fi
  fi
  if printf '%s' "$README" | grep -qiE 'SLSA level|0 threats|ClamAV|virus.?total.{0,15}clean|GitHub Verified'; then
    warn "README advertises security certifications. Genuine projects rarely do; fake ones lean on it."
  fi
fi

# ------------------------------------------------------------------ verdict
echo
echo "────────────────────────────────────────────────────────────"
if (( FLAGS > 0 )); then
  echo "${R}${B}VERDICT: DO NOT USE${N} — ${FLAGS} critical, ${WARNS} warning(s)."
  echo "Do not clone, run, or visit linked download pages."
  exit 1
elif (( WARNS > 0 )); then
  echo "${Y}${B}VERDICT: REVIEW MANUALLY${N} — ${WARNS} warning(s)."
  echo "Read the source and confirm the license before commercial use."
  exit 0
else
  echo "${G}${B}VERDICT: NO RED FLAGS${N}"
  echo "Screening found nothing obvious. Still review the code you intend to run."
  exit 0
fi
