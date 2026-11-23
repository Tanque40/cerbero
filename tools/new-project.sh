#!/bin/sh
# SPDX-License-Identifier: MIT
set -eu

usage() {
    printf '%s\n' 'Usage: sh tools/new-project.sh [--example] [--license-file FILE] DEST' >&2
    exit 2
}

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

example=false
license_file=
while [ "$#" -gt 1 ]; do
    case "$1" in
        --example)
            [ "$example" = false ] || usage
            example=true
            shift
            ;;
        --license-file)
            [ "$#" -ge 3 ] && [ -z "$license_file" ] || usage
            case "$2" in
                ''|-*|*[[:cntrl:]]*) usage ;;
                /*) license_file=$2 ;;
                *) license_file=./$2 ;;
            esac
            shift 2
            ;;
        *) usage ;;
    esac
done
[ "$#" -eq 1 ] || usage
case "$1" in
    ''|-*|*[[:cntrl:]]*) usage ;;
    /*) requested=$1 ;;
    *) requested=./$1 ;;
esac
if [ -n "$license_file" ]; then
    [ -f "$license_file" ] && [ -r "$license_file" ] && [ -s "$license_file" ] ||
        fail 'Choose a readable, nonempty regular file for the project license.'
fi

name=$(basename "$requested")
case "$name" in
    '.'|'..'|'/') fail 'Choose a name for the new project directory.' ;;
esac
parent=$(CDPATH= cd -P "$(dirname "$requested")" && pwd -P) ||
    fail 'Choose an existing parent directory for the new project.'
kit=$(CDPATH= cd -P "$(dirname "$0")/.." && pwd -P)
target=${parent%/}/$name

# Compare directory identity so symlinks and case-insensitive paths work too.
ancestor=$parent
while [ "$ancestor" != / ]; do
    if [ "$ancestor" -ef "$kit" ]; then
        fail 'Choose a destination outside the starter kit.'
    fi
    ancestor=$(dirname "$ancestor")
done

# Only the process that creates the directory may populate or clean it up.
mkdir "$target" || fail 'The destination must be a new directory in a writable parent.'
trap 'rm -rf "$target"' 0
trap 'exit 1' HUP INT TERM
cp -R "$kit/starter/." "$target/"
if [ "$example" = true ]; then
    cp -R "$kit/examples/readiness/." "$target/"
fi
mkdir -p "$target/LICENSES"
cp "$kit/LICENSE" "$target/LICENSES/template-MIT.txt"
if [ -n "$license_file" ]; then
    cp "$license_file" "$target/LICENSE"
fi
trap - 0 HUP INT TERM
printf 'Created %s\n' "$target"
