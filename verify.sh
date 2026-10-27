#!/bin/sh
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$HERE"
fail=0
for f in repro/repro.prog repro/repro.kernsight.prog \
         7.3/serial-7.3.log 7.3/validation-run-20261028/serial.log \
         7.3/RESULT.txt kernel/SOURCES.md; do
  [ -s "$f" ] || { echo "MISSING $f"; fail=1; }
done
grep -q 'Log size 516 blocks too small, minimum size is 636 blocks' 7.3/validation-run-20261028/serial.log || { echo "missing 516/636"; fail=1; }
grep -q 'file: fs/xfs/xfs_log.c, line: 597' 7.3/validation-run-20261028/serial.log || { echo "missing 597"; fail=1; }
grep -q 'xfs_log_mount' 7.3/validation-run-20261028/serial.log || { echo "missing xfs_log_mount"; fail=1; }
grep -q '^CONFIG_XFS_ASSERT_FATAL=y' kernel/kernel-7.3.config || { echo "ASSERT_FATAL off"; fail=1; }
sha256sum -c MANIFEST.sha256 >/dev/null || { echo "manifest mismatch"; fail=1; }
[ "$fail" = 0 ] && echo PASS || exit 1
