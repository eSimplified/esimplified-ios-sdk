#!/usr/bin/env python3
"""Rebuild the repository tables in SDK_API_REFERENCE.md from the protocol sources."""

import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROTOCOLS = ROOT / "Sources/EsimplifiedSDK/Repository"
REFERENCE = ROOT / "SDK_API_REFERENCE.md"


def parse(path):
    lines = path.read_text().split("\n")
    found = defaultdict(list)
    for index, line in enumerate(lines, 1):
        match = re.match(r"\s*func (\w+)\(", line)
        if not match:
            continue
        signature, cursor = line.strip(), index
        while signature.count("(") > signature.count(")") and cursor < len(lines):
            signature += " " + lines[cursor].strip()
            cursor += 1
        signature = re.sub(r"\s+", " ", signature).split(" {")[0].rstrip()
        signature = signature.replace("( ", "(").replace(" )", ")")
        found[match.group(1)].append(signature)
    return found


def preferred(signatures):
    return sorted(signatures, key=lambda s: (-s.count(" = "), len(s)))[0]


def rows_for(path):
    methods = parse(path)
    return [
        f"| `{name}` | `{preferred(signatures)}` |"
        for name, signatures in sorted(methods.items())
    ]


def main():
    text = REFERENCE.read_text()
    blocks = re.split(r"^### ", text, flags=re.M)
    rebuilt, replaced, total = [blocks[0]], 0, 0

    for block in blocks[1:]:
        name = block.split("\n", 1)[0].strip()
        source = PROTOCOLS / f"{name}Type.swift"
        if not source.exists() or "| Method | Signature |" not in block:
            rebuilt.append(block)
            continue
        rows = rows_for(source)
        total += len(rows)
        replaced += 1
        table = "| Method | Signature |\n|---|---|\n" + "\n".join(rows)
        block = re.sub(
            r"\| Method \| Signature \|\n\|---\|---\|\n(?:\|.*\n?)*",
            table + "\n",
            block,
        )
        rebuilt.append(block)

    text = "### ".join(rebuilt)
    text = re.sub(
        r"\d+ signatures across \d+ repositories\. Where a method is listed more than once these are real overloads — the shortest form is the one to reach for, the longer ones let you override the cache lifetime or ask for extra data\.",
        f"{total} methods across {replaced} repositories. Each row shows the form you call, with its default arguments. "
        "Cached reads also accept a `cacheTTL: TimeInterval` you can pass to override the lifetime shown in section 8.",
        text,
    )
    REFERENCE.write_text(text)
    print(f"{replaced} repositories, {total} methods")


if __name__ == "__main__":
    sys.exit(main())
