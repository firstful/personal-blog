#!/usr/bin/env python3
"""
Validate all TypeScript modules under src/ts/ are wired up in main.ts.

Scans each .ts file for exported functions (cross-referenced against main.ts imports),
then checks the exports appear in the boot:complete handler or are explicitly listed
in a skip comment block at the top of main.ts.

Usage:
    python3 scripts/validate-ts-modules.py
    exit code 0 = all clear, non-zero = issues found
"""

import os
import re
import sys

SRC_TS = os.path.join(os.path.dirname(__file__), '..', 'src', 'ts')
MAIN_TS = os.path.join(SRC_TS, 'main.ts')

# ── Files that are purely utility/concept modules  ──
# These don't need to be imported in main.ts because they're
# transitively imported by other modules or provide shared types.
SKIP_FILES = {
    'storage.ts',           # utility — used by read-tracker.ts
}


def get_ts_files():
    """Return set of .ts filenames under src/ts/."""
    files = set()
    for f in os.listdir(SRC_TS):
        if f.endswith('.ts') and os.path.isfile(os.path.join(SRC_TS, f)):
            files.add(f)
    return files


def get_exported_functions(filepath):
    """Return set of exported function names from a TypeScript file."""
    exports = set()
    try:
        with open(filepath, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        return exports

    # Match `export function foo(...` and `export async function foo(...`
    for m in re.finditer(r'^export\s+(?:async\s+)?function\s+(\w+)', content, re.MULTILINE):
        exports.add(m.group(1))

    # Match `export const foo = ...` — skip simple values, keep arrow functions
    # This is a looser match; we'll filter below
    for m in re.finditer(r'^export\s+(?:const|let|var)\s+(\w+)\s*=\s*(?:\(|async|function)', content, re.MULTILINE):
        exports.add(m.group(1))

    return exports


def get_main_imports():
    """Return set of all imported symbols in main.ts."""
    imports = set()
    try:
        with open(MAIN_TS, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        return imports

    # Match `import { a, b as c } from './foo'`
    for m in re.finditer(r'import\s+\{([^}]+)\}\s*from\s+[\'\"].+?[\'\"]', content):
        symbols = m.group(1).split(',')
        for sym in symbols:
            # Handle `as` aliases — track the alias, not the original
            name = sym.strip().split(' as ')[-1].strip()
            if name:
                imports.add(name)

    return imports


def get_main_skip_films():
    """
    Return set of filenames explicitly skipped in main.ts via a comment:
    // skip: console-tray.ts — reason
    """
    skipped = set()
    try:
        with open(MAIN_TS, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        return skipped

    for m in re.finditer(r'//\s*skip:\s*(\S+)', content):
        skipped.add(m.group(1).rstrip(','))
    return skipped


def get_init_handler_calls():
    """Return set of function names called inside the boot:complete handler."""
    calls = set()
    try:
        with open(MAIN_TS, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        return calls

    # Find the boot:complete handler block
    m = re.search(
        r"document\.addEventListener\s*\(\s*['\"]boot:complete['\"]\s*,.*?\{.*?\}\s*,\s*\{",
        content, re.DOTALL
    )
    if m:
        handler = m.group(0)
        for m2 in re.finditer(r'^\s+(\w+)\s*\(', handler, re.MULTILINE):
            name = m2.group(1)
            if name not in ('if', 'for', 'while', 'switch', 'return', 'catch', 'else', 'try'):
                calls.add(name)

    # Also check for calls outside the handler (top-level init calls)
    for m2 in re.finditer(r'^(?:init\w+)\s*\(', content, re.MULTILINE):
        name = m2.group(0).rstrip('(')
        calls.add(name)

    return calls


def main():
    errors = []
    ts_files = get_ts_files()
    imports = get_main_imports()
    skip_files = get_main_skip_films()
    handler_calls = get_init_handler_calls()

    for filename in sorted(ts_files):
        if filename == 'main.ts':
            continue
        if filename in SKIP_FILES:
            continue

        filepath = os.path.join(SRC_TS, filename)
        exports = get_exported_functions(filepath)

        if not exports:
            # File with no exports — could be just side-effect types/styles
            # Check if it's at least imported somewhere
            continue

        if filename in skip_files:
            continue

        # Every exported init* function must be imported AND called in main.ts
        # Non-init exports (utility functions) may be internal — only warn about them
        for func in exports:
            if func.startswith('init') or func.startswith('mark') or func.startswith('apply'):
                if func not in imports:
                    errors.append(f'{filename}: exports init function "{func}" but is not imported in main.ts')
                elif func not in handler_calls:
                    errors.append(f'{filename}: "{func}" is imported but never called in main.ts')

    if errors:
        print('ERROR: TypeScript module validation failed')
        for err in errors:
            print(f'  ✗ {err}')
        print()
        print('To fix:')
        print('  1. Add the missing import to src/ts/main.ts')
        print('  2. Add the init call in the boot:complete handler')
        print('  3. Or add a skip comment:  // skip: file.ts — reason for skipping')
        sys.exit(1)
    else:
        print('✓ All TypeScript modules are properly wired up in main.ts')
        sys.exit(0)


if __name__ == '__main__':
    main()
