#!/usr/bin/env python3
# ============================================================
# aop-file-watcher.py — Python file watcher using watchdog
# ============================================================
#
# Purpose:  Monitors a directory for AOP_COMPLETE_*.json creation
#           events and writes signal files for the Orchestrator.
#           Detection latency: <1 second.
#
# Usage:    python3 scripts/aop-file-watcher.py <watch_dir> <signal_dir>
#
# Dependencies: watchdog (pip install watchdog)
#
# Example:
#   python3 scripts/aop-file-watcher.py /c/ai/target-project /c/ai/target-project/signals
#
# Signal files:
#   When AOP_COMPLETE_foo_a1b2.json is created, the watcher writes:
#     <signal_dir>/SIGNAL_AOP_COMPLETE_foo_a1b2.txt
#   containing the full path to the artifact.
#
# The Orchestrator checks for signal files instead of polling:
#   SIGNAL="SIGNAL_AOP_COMPLETE_${tid}_${SESSION_ID}.txt"
#   if test -f "${SIGNAL_DIR}/${SIGNAL}"; then
#     ARTIFACT_PATH=$(cat "${SIGNAL_DIR}/${SIGNAL}")
#     EXECUTOR_STATUS[$tid]="COMPLETE"
#   fi
# ============================================================

import sys
import time
from pathlib import Path

try:
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler
except ImportError:
    print("ERROR: watchdog not installed. Run: pip install watchdog", file=sys.stderr)
    sys.exit(1)

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} <watch_dir> <signal_dir>", file=sys.stderr)
    sys.exit(1)

WATCH_DIR = sys.argv[1]
SIGNAL_DIR = sys.argv[2]

# Ensure signal directory exists
Path(SIGNAL_DIR).mkdir(parents=True, exist_ok=True)


class ArtifactHandler(FileSystemEventHandler):
    def on_created(self, event):
        p = Path(event.src_path)
        if p.name.startswith("AOP_COMPLETE_") and p.suffix == ".json":
            sig = Path(SIGNAL_DIR) / f"SIGNAL_{p.stem}.txt"
            sig.write_text(str(p))
            print(f"[watcher] Signal written: {sig.name}", flush=True)


observer = Observer()
observer.schedule(ArtifactHandler(), WATCH_DIR, recursive=False)
observer.start()
print(f"[watcher] Monitoring {WATCH_DIR} for AOP_COMPLETE_*.json ...", flush=True)

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()

observer.join()
