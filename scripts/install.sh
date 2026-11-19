#!/usr/bin/env bash
# macOS, Linux, and WSL installer. Mirrors scripts/install.ps1.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES="$ROOT/rules/progressive-agentic-coding.md"
SKILLS="$ROOT/skills"
START='# BEGIN PROGRESSIVE AGENTIC CODING (managed)'
END='# END PROGRESSIVE AGENTIC CODING (managed)'

AGENT_ARGS=()
FORCE=0
WHAT_IF=0
REPLACE=0
ASKED=0
SELECTED=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agents)
      [[ $# -ge 2 ]] || { echo "provide comma-separated agent names" >&2; exit 2; }
      AGENT_ARGS+=("$2")
      shift 2
      ;;
    --force) FORCE=1; shift ;;
    --dry-run) WHAT_IF=1; shift ;;
    *) echo "Unrecognized argument: $1" >&2; exit 2 ;;
  esac
done
if [[ ${#AGENT_ARGS[@]} -eq 0 ]]; then
  AGENT_ARGS=(all)
fi
if (( FORCE )); then
  REPLACE=1
fi

normalize() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value" | LC_ALL=C tr '[:upper:]' '[:lower:]'
}

add_selected() {
  local name="$1" i
  for (( i = 0; i < ${#SELECTED[@]}; i++ )); do
    [[ "${SELECTED[i]}" == "$name" ]] && return 0
  done
  SELECTED+=("$name")
}

wants() {
  local name="$1" i
  for (( i = 0; i < ${#SELECTED[@]}; i++ )); do
    [[ "${SELECTED[i]}" == "$name" ]] && return 0
  done
  return 1
}

select_agents() {
  local value agent normalized saw_all=0
  local -a parts
  for value in "${AGENT_ARGS[@]}"; do
    IFS=',' read -ra parts <<< "$value"
    for agent in "${parts[@]}"; do
      normalized="$(normalize "$agent")"
      if [[ "$normalized" == all ]]; then
        SELECTED=(cursor claude codex opencode)
        saw_all=1
        break
      fi
      case "$normalized" in
        cursor|claude|codex|opencode) add_selected "$normalized" ;;
        *) echo "Unsupported agent: $agent" >&2; exit 2 ;;
      esac
    done
    if (( saw_all )); then
      break
    fi
  done
  if [[ ${#SELECTED[@]} -eq 0 ]]; then
    SELECTED=(cursor claude codex opencode)
  fi
}

read_exact() {
  local dest="$1" file="$2" data
  data="$(cat -- "$file"; printf x)"
  printf -v "$dest" '%s' "${data%x}"
}

trim_end_into() {
  local dest="$1" value="$2"
  value="${value%"${value##*[![:space:]]}"}"
  printf -v "$dest" '%s' "$value"
}

confirm_overwrite() {
  local reply
  if (( REPLACE || ASKED || WHAT_IF )); then
    return 0
  fi
  ASKED=1
  if [[ ! -t 0 ]]; then
    return 0
  fi
  printf 'Overwrite existing installed files? [y/N] ' >&2
  IFS= read -r reply || true
  case "$(normalize "$reply")" in
    y|yes) REPLACE=1 ;;
  esac
}

backup() {
  local path="$1" hex destination
  [[ -e "$path" ]] || return 0
  hex="$(od -An -N3 -tx1 /dev/urandom | tr -d '[:space:]')"
  destination="$path.bak.$(date +%Y%m%d%H%M%S)-$hex"
  if (( WHAT_IF )); then
    printf '[preview] Backup %s to %s\n' "$path" "$destination"
  else
    cp -R -- "$path" "$destination"
  fi
}

install_skills() {
  local dir="$1" name source dest
  for name in progressive-build progressive-review reconcile-feedback open-review-worktree review-loop; do
    source="$SKILLS/$name"
    dest="$dir/$name"
    if [[ -e "$dest" ]]; then
      confirm_overwrite
      if (( ! REPLACE )); then
        if (( ASKED )) && [[ -t 0 ]]; then
          printf '[skip] %s (left unchanged)\n' "$dest"
        else
          printf '[skip] %s (already exists; pass --force to replace)\n' "$dest"
        fi
        continue
      fi
      backup "$dest"
      if (( ! WHAT_IF )); then
        rm -rf -- "$dest"
      fi
    fi
    if (( WHAT_IF )); then
      printf '[preview] Copy %s to %s\n' "$source" "$dest"
      continue
    fi
    mkdir -p -- "$dir"
    cp -R -- "$source" "$dest"
    printf '[installed] %s\n' "$dest"
  done
}

read_exact RULE_TEXT "$RULES"
trim_end_into RULE_TEXT "$RULE_TEXT"
BLOCK="${START}"$'\n'"${RULE_TEXT}"$'\n'"${END}"

install_rule() {
  local path="$1" original="" prefix rest suffix new_text dir tmp
  if [[ -f "$path" ]]; then
    read_exact original "$path"
  elif [[ -e "$path" ]]; then
    echo "Cannot install rules into $path; it is not a file." >&2
    exit 1
  fi
  prefix="${original%%"$START"*}"
  if [[ "$prefix" != "$original" ]]; then
    rest="${original#"$prefix$START"}"
    case "$rest" in
      *"$END"*) ;;
      *) echo "Incomplete managed block in $path. Fix it manually first." >&2; exit 1 ;;
    esac
    suffix="${rest#*"$END"}"
    new_text="${prefix}${BLOCK}${suffix}"
  else
    trim_end_into new_text "$original"
    new_text="${new_text}"$'\n\n'"${BLOCK}"$'\n'
  fi
  if [[ "$new_text" == "$original" ]]; then
    printf '[unchanged] %s\n' "$path"
    return
  fi
  if (( WHAT_IF )); then
    printf '[preview] Update managed rules block in %s\n' "$path"
    return
  fi
  backup "$path"
  dir="$(dirname -- "$path")"
  mkdir -p -- "$dir"
  tmp="$(mktemp "${dir}/.progressive-install.XXXXXX")"
  printf '%s' "$new_text" > "$tmp"
  mv -f -- "$tmp" "$path"
  printf '[installed] %s\n' "$path"
}

select_agents

if wants cursor; then
  install_skills "$HOME/.cursor/skills"
  printf '[manual] Paste %s into Cursor > Customize > Rules > User Rules\n' "$RULES"
  printf '%s\n' '[manual] To sync to Cursor Cloud Agents: Settings > Agents > Context and Tools > Sync Skills for Cloud Agents'
fi
if wants claude; then
  install_skills "$HOME/.claude/skills"
  install_rule "$HOME/.claude/CLAUDE.md"
fi
if wants codex || wants opencode; then
  install_skills "$HOME/.agents/skills"
fi
if wants codex; then
  install_rule "$HOME/.codex/AGENTS.md"
fi
if wants opencode; then
  install_rule "$HOME/.config/opencode/AGENTS.md"
fi
if (( WHAT_IF )); then
  printf '%s\n' 'Preview only; no files were modified.'
fi
