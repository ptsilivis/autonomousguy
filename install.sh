#!/usr/bin/env bash
# autonomousguy installer — no Node.js required
# Usage (from a cloned repo):
#   bash install.sh
#
# Or pipe directly from GitHub:
#   curl -fsSL https://raw.githubusercontent.com/ptsilivis/autonomousguy/main/install.sh | bash

set -euo pipefail

VERSION="0.1.0"

TOOL_NAMES=("Claude Code" "GitHub Copilot" "Cursor" "Gemini CLI" "ChatGPT Codex" "OpenCode" "JetBrains AI" "General Agent")
TOOL_DIRS=(".claude" ".github" ".cursor" ".gemini" ".agents" ".opencode" ".idea" ".autonomousguy")

# ---------------------------------------------------------------------------
# Locate skills directory
# ---------------------------------------------------------------------------
if [ -n "${BASH_SOURCE[0]+x}" ] && [ "${BASH_SOURCE[0]}" != "" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$(pwd)"
fi
SKILLS_DIR="$SCRIPT_DIR/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  # Piped from curl — download the archive
  echo "Downloading autonomousguy skills..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  curl -fsSL "https://github.com/ptsilivis/autonomousguy/archive/refs/heads/master.tar.gz" \
    | tar -xz -C "$TMP_DIR" --strip-components=1
  SKILLS_DIR="$TMP_DIR/skills"
fi

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Error: could not locate skills/ directory." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Intro
# ---------------------------------------------------------------------------
echo ""
echo "autonomousguy v$VERSION"
echo "AI skill prompts for embedded automotive engineers"
echo ""

# ---------------------------------------------------------------------------
# 1. Scope
# ---------------------------------------------------------------------------
echo "Install scope:"
echo "  1) Local  — installs into the current directory"
echo "  2) Global — installs into your home directory"
read -rp "Enter 1 or 2 [1]: " scope_choice
scope_choice="${scope_choice:-1}"

if [[ "$scope_choice" == "2" ]]; then
  BASE_DIR="$HOME"
  SCOPE_LABEL="global"
else
  BASE_DIR="$(pwd)"
  SCOPE_LABEL="local"
fi

# ---------------------------------------------------------------------------
# 2. Tools
# ---------------------------------------------------------------------------
echo ""
echo "Which AI tool(s)? Enter comma-separated numbers, or 'a' for all."
for i in "${!TOOL_NAMES[@]}"; do
  printf "  %d) %s\n" $((i + 1)) "${TOOL_NAMES[$i]}"
done
read -rp "Selection [a]: " tools_input
tools_input="${tools_input:-a}"

SELECTED_TOOL_INDICES=()
if [[ "$tools_input" =~ ^[Aa]$ ]]; then
  for i in "${!TOOL_NAMES[@]}"; do SELECTED_TOOL_INDICES+=("$i"); done
else
  IFS=',' read -ra parts <<< "$tools_input"
  for p in "${parts[@]}"; do
    p="${p// /}"
    if [[ "$p" =~ ^[0-9]+$ ]] && (( p >= 1 && p <= ${#TOOL_NAMES[@]} )); then
      SELECTED_TOOL_INDICES+=($((p - 1)))
    fi
  done
fi

if [[ ${#SELECTED_TOOL_INDICES[@]} -eq 0 ]]; then
  echo "No valid tools selected. Aborting." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 3. Skills
# ---------------------------------------------------------------------------
mapfile -t CATEGORIES < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort | xargs -I{} basename {})

TOTAL=0
for cat in "${CATEGORIES[@]}"; do
  count=$(find "$SKILLS_DIR/$cat" -name "*.md" | wc -l | tr -d ' ')
  TOTAL=$((TOTAL + count))
done

echo ""
read -rp "Install all $TOTAL skills? [Y/n]: " install_all
install_all="${install_all:-y}"

SELECTED_CATS=("${CATEGORIES[@]}")

if [[ ! "$install_all" =~ ^[Yy] ]]; then
  echo ""
  echo "Available categories:"
  for i in "${!CATEGORIES[@]}"; do
    count=$(find "$SKILLS_DIR/${CATEGORIES[$i]}" -name "*.md" | wc -l | tr -d ' ')
    printf "  %d) %-22s (%s skills)\n" $((i + 1)) "${CATEGORIES[$i]}" "$count"
  done
  read -rp "Enter comma-separated numbers (or 'a' for all) [a]: " cats_input
  cats_input="${cats_input:-a}"

  if [[ ! "$cats_input" =~ ^[Aa]$ ]]; then
    SELECTED_CATS=()
    IFS=',' read -ra parts <<< "$cats_input"
    for p in "${parts[@]}"; do
      p="${p// /}"
      if [[ "$p" =~ ^[0-9]+$ ]] && (( p >= 1 && p <= ${#CATEGORIES[@]} )); then
        SELECTED_CATS+=("${CATEGORIES[$((p - 1))]}")
      fi
    done
  fi
fi

if [[ ${#SELECTED_CATS[@]} -eq 0 ]]; then
  echo "No categories selected. Aborting." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 4. Copy
# ---------------------------------------------------------------------------
echo ""
echo "Installing..."
echo ""
COPIED=0

for idx in "${SELECTED_TOOL_INDICES[@]}"; do
  tool_name="${TOOL_NAMES[$idx]}"
  tool_dir="${TOOL_DIRS[$idx]}"
  dest_base="$BASE_DIR/$tool_dir/skills/autonomousguy"

  for cat in "${SELECTED_CATS[@]}"; do
    src_cat="$SKILLS_DIR/$cat"
    dest_cat="$dest_base/$cat"
    mkdir -p "$dest_cat"
    for f in "$src_cat"/*.md; do
      [ -f "$f" ] || continue
      cp "$f" "$dest_cat/"
      COPIED=$((COPIED + 1))
    done
  done

  if [[ "$SCOPE_LABEL" == "global" ]]; then
    rel="~/$tool_dir/skills/autonomousguy"
  else
    rel="./$tool_dir/skills/autonomousguy"
  fi
  printf "  ✓ %-18s → %s\n" "$tool_name" "$rel"
done

# ---------------------------------------------------------------------------
# 5. Summary
# ---------------------------------------------------------------------------
skill_count=$((COPIED / ${#SELECTED_TOOL_INDICES[@]}))
echo ""
echo "Installed $skill_count skills across ${#SELECTED_TOOL_INDICES[@]} tool(s)."
echo ""
echo "To use a skill: paste its contents into your AI tool of choice,"
echo "or invoke it by name if your tool supports skill discovery."
echo ""

for cat in "${SELECTED_CATS[@]}"; do
  if [[ "$cat" == "workspace" ]]; then
    echo "Tip: run the [codebase-analysis] skill first in a new project to"
    echo "generate .autonomousguy/CODEBASE_MAP.md — all other skills will"
    echo "reference it automatically."
    echo ""
    break
  fi
done
