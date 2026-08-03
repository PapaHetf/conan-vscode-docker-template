#!/usr/bin/env python3
"""Печатает .cpp-файлы проекта из compile_commands.json (без libraries/)."""
import json
import sys

db = sys.argv[1] if len(sys.argv) > 1 else "build/Debug/compile_commands.json"
with open(db, encoding="utf-8") as f:
    files = {e["file"] for e in json.load(f) if "/libraries/" not in e["file"]}
print("\n".join(sorted(files)))
