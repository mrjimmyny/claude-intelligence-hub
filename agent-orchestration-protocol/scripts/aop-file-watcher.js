#!/usr/bin/env node
// ============================================================
// aop-file-watcher.js — Node.js file watcher using chokidar
// ============================================================
//
// Purpose:  Monitors a directory for AOP_COMPLETE_*.json creation
//           events and writes signal files for the Orchestrator.
//           Detection latency: <1 second.
//
// Usage:    node scripts/aop-file-watcher.js <watch_dir> <signal_dir>
//
// Dependencies: chokidar (npm install chokidar)
//
// Example:
//   node scripts/aop-file-watcher.js /c/ai/target-project /c/ai/target-project/signals
//
// Signal files:
//   When AOP_COMPLETE_foo_a1b2.json is created, the watcher writes:
//     <signal_dir>/SIGNAL_AOP_COMPLETE_foo_a1b2.txt
//   containing the full path to the artifact.
// ============================================================

const fs = require('fs');
const path = require('path');

let chokidar;
try {
  chokidar = require('chokidar');
} catch (e) {
  console.error('ERROR: chokidar not installed. Run: npm install chokidar');
  process.exit(1);
}

const [watchDir, signalDir] = process.argv.slice(2);

if (!watchDir || !signalDir) {
  console.error(`Usage: ${process.argv[1]} <watch_dir> <signal_dir>`);
  process.exit(1);
}

// Ensure signal directory exists
fs.mkdirSync(signalDir, { recursive: true });

chokidar
  .watch(path.join(watchDir, 'AOP_COMPLETE_*.json'), { ignoreInitial: true })
  .on('add', (filePath) => {
    const stem = path.basename(filePath, '.json');
    const sig = path.join(signalDir, `SIGNAL_${stem}.txt`);
    fs.writeFileSync(sig, filePath);
    console.log(`[watcher] Signal written: SIGNAL_${stem}.txt`);
  });

console.log(`[watcher] Monitoring ${watchDir} for AOP_COMPLETE_*.json ...`);
