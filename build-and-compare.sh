#!/usr/bin/env bash
SRC=example.typ
OUT=example.pdf
REF=example-ref.pdf

typst compile $SRC $OUT
echo "built: $(du -sh $OUT)"

if diff -q $REF $OUT >/dev/null 2>&1; then
    echo "diff result: identical ✓"
else
    echo "diff result: different ✗"
fi
