# xfs: undersized log triggers assertion in xfs_log_mount()

Reproduction materials for a syzkaller report:

```
kernel BUG in xfs_assert: NUM (fs/xfs/xfs_log.c line593)
```

## Status

- Trigger: executing the state-construction recipe
  `repro/repro.kernsight.prog` alone on Linux 7.3.0-kernsight-kasan triggers
  the log-size assertion in `xfs_log_mount()` at 177.80 s.
- The smaller `repro/repro.prog` is not needed.
- Reproduction count: one crash observed in one fresh-VM validation run
  (2026-10-28; `7.3/validation-run-20261028/`).
- Taint: Not tainted.
- The check is the log size check (516 < 636 blocks), followed by
  `XFS: Assertion failed: 0, file: fs/xfs/xfs_log.c, line: 597`.
- XFS config: CONFIG_XFS_DEBUG=y, CONFIG_XFS_DEBUG_EXPENSIVE=y,
  CONFIG_XFS_ASSERT_FATAL=y.
- This is an observable assertion with a malformed image; it does not claim
  a new vulnerability or a specific root cause.

## Contents

```
repro/repro.kernsight.prog   state-construction recipe (~1.4 MB)
repro/repro.prog             small testcase (~2.5 KB; NOT needed)
7.3/serial-7.3.log           earlier 2026-10-27 boot-to-crash serial
7.3/console-7.3.log, 7.3/cmdline-7.3.txt, 7.3/boot-info-7.3.txt
7.3/validation-run-20261028/ 2026-10-28 recipe-only validation
                             (serial log, boot information, kernel command line)
kernel/kernel-7.3.config, kernel/SOURCES.md
reproduce.sh, verify.sh, MANIFEST.sha256
```

## Reproduction

```
./reproduce.sh
```

Manual form:

```
scp syz-execprog syz-executor repro/repro.kernsight.prog root@guest:/tmp/
ssh root@guest
cd /tmp && chmod +x syz-execprog syz-executor
./syz-execprog -procs=1 -repeat=1 -disable=swap -executor ./syz-executor ./repro.kernsight.prog
```

## Observed on 7.3.0

```
XFS (loop0): Log size 516 blocks too small, minimum size is 636 blocks
XFS (loop0): AAIEEE! Log failed size checks. Abort!
XFS: Assertion failed: 0, file: fs/xfs/xfs_log.c, line: 597
kernel BUG at fs/xfs/xfs_message.c:102!
RIP: 0010:assfail+0xa2/0xb0
 xfs_log_mount+0x4e3/0x590
Kernel panic - not syncing: Fatal exception
```
