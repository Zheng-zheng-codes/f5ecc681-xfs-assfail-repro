#!/bin/sh
set -eu
G=${GUEST:-root@127.0.0.1}
PORT=${PORT:-10022}
KEY=${KEY:-/data/zhengzheng/kernsight/vm/trixie.id_rsa}
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
scp -i "$KEY" -P "$PORT" \
  syz-execprog syz-executor "$HERE/repro/repro.kernsight.prog" "$G:/tmp/"
ssh -i "$KEY" -p "$PORT" "$G" \
  'cd /tmp && chmod +x syz-execprog syz-executor && \
   ./syz-execprog -procs=1 -repeat=1 -disable=swap -executor ./syz-executor ./repro.kernsight.prog'
