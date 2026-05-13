#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$ROOT/shared"
USAGE_RUN="$SHARED/usage.jsonl"
USAGE_ALL="$HOME/.agent-collab/usage-all.jsonl"
MARKDOWN=false
[ "$1" = "--markdown" ] && MARKDOWN=true

parse_jsonl() {
  local file="$1"
  [ ! -f "$file" ] && echo "0 0 0 0 0" && return
  python3 -c "
import sys, json
total_in, total_out, cache_w, cache_r, total = 0, 0, 0, 0, 0
for line in open('$file'):
    try:
        d = json.loads(line)
        t = d.get('part', {}).get('tokens', {})
        total_in += t.get('input', 0)
        total_out += t.get('output', 0)
        cache = t.get('cache', {})
        cache_w += cache.get('write', 0)
        cache_r += cache.get('read', 0)
        total += t.get('total', 0)
    except: pass
print(total_in, total_out, cache_w, cache_r, total)
" 2>/dev/null || echo "0 0 0 0 0"
}

read -r in_run out_run cw_run cr_run tot_run < <(parse_jsonl "$USAGE_RUN")
read -r in_all out_all cw_all cr_all tot_all < <(parse_jsonl "$USAGE_ALL")

format_num() { printf "%'.0f" "$1" 2>/dev/null || echo "$1"; }

if $MARKDOWN; then
  echo ""
  echo "## Token Usage"
  echo ""
  echo "| | Input | Output | Cache Write | Cache Read | Total |"
  echo "|---|---|---|---|---|---|"
  printf "| This run | %s | %s | %s | %s | %s |\n" \
    "$(format_num $in_run)" "$(format_num $out_run)" \
    "$(format_num $cw_run)" "$(format_num $cr_run)" "$(format_num $tot_run)"
  printf "| All sessions | %s | %s | %s | %s | %s |\n" \
    "$(format_num $in_all)" "$(format_num $out_all)" \
    "$(format_num $cw_all)" "$(format_num $cr_all)" "$(format_num $tot_all)"
else
  echo "Token Usage:"
  echo "  This run - Total: $(format_num $tot_run)  (in: $in_run, out: $out_run, cache_w: $cw_run, cache_r: $cr_run)"
  echo "  All sessions - Total: $(format_num $tot_all)"
fi
