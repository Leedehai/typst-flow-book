#!/usr/bin/env bash
SRC=example.typ
OUT=example.pdf
REF=example-ref.pdf

typst compile $SRC $OUT
if [ $? -ne 0 ]; then
    exit 1
fi
echo "built: $(du -sh $OUT)"

if diff -q $REF $OUT >/dev/null 2>&1; then
    printf "\033[32mdiff result: identical ✓\n\033[0m"
else
    printf "\033[33mdiff result: different ✗\n\033[0m"
fi
