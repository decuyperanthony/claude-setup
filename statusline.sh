#!/usr/bin/env python3
"""Claude Code custom status line — dark + green theme.
Shows: name · model (+ context-window size) · current folder · git branch · context-usage bar.

Reads the status JSON on stdin (Claude Code passes it), prints one line.
Wire it via ~/.claude/settings.json:

    "statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 0 }

then: chmod +x ~/.claude/statusline.sh

Customise the CONFIG block below (name, accent, kaomoji) and the colours / emojis further down.
"""
import json
import os
import subprocess
import sys

# ---- CONFIG ----
NAME = "decuyperanthony"   # your handle — leave "" to fall back to git user.name / $USER
KAOMOJI = "(◍•ᴗ•◍) ·˚✦"
DOT = "🟢"                 # small prefix mark before the name
# ----------------

# ANSI colors
GREEN = "\033[92m"; DGREEN = "\033[32m"; ORANGE = "\033[38;5;215m"
YELLOW = "\033[33m"; RED = "\033[31m"; GREY = "\033[90m"
RESET = "\033[0m"; BOLD = "\033[1m"


def sh(args, cwd=None):
    try:
        return subprocess.check_output(args, cwd=cwd or None,
                                       stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

ws = data.get("workspace") or {}
cwd = ws.get("current_dir") or data.get("cwd") or os.getcwd()

# Model + context-window size label
model = (data.get("model") or {}).get("display_name", "Claude")
cw = data.get("context_window") or {}
size = cw.get("context_window_size") or 0
ctx_label = "1M" if size >= 1_000_000 else ("200k" if size else "")
pct = cw.get("used_percentage")
pct = int(pct) if pct is not None else 0

# Folder (last path component)
folder = os.path.basename(cwd.rstrip("/")) or cwd

# Name
name = NAME or sh(["git", "-C", cwd, "config", "user.name"]) or os.environ.get("USER", "")

# Git branch (prefer worktree branch when in a --worktree session)
branch = (data.get("worktree") or {}).get("branch") or sh(["git", "-C", cwd, "branch", "--show-current"])

# Context % color (functional: green -> yellow -> red as context fills)
ctx_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN

sep = f" {GREY}♡{RESET} "

parts = [f"{DOT} {BOLD}{GREEN}{name}{RESET}"]

mdl = f"{GREEN}{model}{RESET}"
if ctx_label:
    mdl += f" {GREY}({ctx_label} context){RESET}"
parts.append(mdl)

if folder:
    parts.append(f"{DGREEN}📁 {folder}{RESET}")
if branch:
    parts.append(f"{DGREEN}🌿 {branch}{RESET}")

# Battery-style context bar: fills up as context is consumed.
BAR_WIDTH = 10
filled = min(BAR_WIDTH, round(pct / 100 * BAR_WIDTH))
bar = f"{ctx_color}{'█' * filled}{GREY}{'░' * (BAR_WIDTH - filled)}{RESET}"
parts.append(f"{ctx_color}◌ ctx {pct}%{RESET} {bar} {GREY}{KAOMOJI}{RESET}")

print(sep.join(parts))
