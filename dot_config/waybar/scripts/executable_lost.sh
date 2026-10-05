#!/usr/bin/env bash
s=$(cut -d. -f1 /proc/uptime)
h=$((s/3600)); m=$(((s%3600)/60))
if [ "$h" -gt 0 ]; then echo "lost ${h}h ${m}m"; else echo "lost ${m}m"; fi
