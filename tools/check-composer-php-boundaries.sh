#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
export COMPOSER_HOME="$scratch/home"
export COMPOSER_CACHE_DIR="$scratch/cache"
unset COMPOSER COMPOSER_IGNORE_PLATFORM_REQ COMPOSER_IGNORE_PLATFORM_REQS

for test_case in 8.4.26:reject 8.4.27:accept 8.5.0:reject 8.5.11:reject 8.5.12:accept 8.6.0:reject; do
    version="${test_case%:*}"
    expected="${test_case#*:}"
    php -r '
        $manifest = json_decode(file_get_contents($argv[1]), true, 512, JSON_THROW_ON_ERROR);
        echo json_encode([
            "require" => ["php" => $manifest["require"]["php"]],
            "config" => ["platform" => ["php" => $argv[2]]],
            "repositories" => [["packagist.org" => false]],
        ], JSON_THROW_ON_ERROR);
    ' "$root/composer.json" "$version" > "$scratch/composer.json"

    if composer --working-dir="$scratch" update --dry-run --no-interaction --no-progress --no-plugins --no-scripts > "$scratch/result" 2>&1; then
        actual=accept
    else
        actual=reject
        if ! grep -Fq "Root composer.json requires php" "$scratch/result"; then
            cat "$scratch/result" >&2
            exit 1
        fi
    fi

    if [[ "$actual" != "$expected" ]]; then
        printf 'PHP %s expected %s, got %s\n' "$version" "$expected" "$actual" >&2
        cat "$scratch/result" >&2
        exit 1
    fi

    printf 'PHP %s: %s\n' "$version" "$actual"
done
