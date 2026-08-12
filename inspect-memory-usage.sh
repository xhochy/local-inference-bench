#!/bin/bash

set -euxo pipefail

[[ -f $1 ]] || { echo "no such file: $1" >&2; exit 1; }
log_file=$(printf %s "$1" | openssl dgst -sha256 -r | cut -d' ' -f1).log

echo "Logging to $log_file"

llama-bench -m $* -ngl 99 -n 0 -p 4096 -d ${BASE_CONTEXT:-262144} --verbose --no-warmup -r 1 >$log_file 2>&1 || (cat $log_file; exit 1)
rg '^load_tensors:.*model buffer size' $log_file
rg '^llama_kv_cache: size =' $log_file
rg '^~llama_context:.*compute buffer size is' $log_file
