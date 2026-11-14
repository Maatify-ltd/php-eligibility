#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
candidate="$(git rev-parse --verify "${1:-HEAD}^{commit}")"
scratch="$(mktemp -d)"
cleanup() {
    if [[ -f "$scratch/checkout/.git" ]]; then
        git worktree remove "$scratch/checkout"
    fi
    rm -rf "$scratch"
}
trap cleanup EXIT

git archive --format=tar "$candidate" > "$scratch/git.tar"
git worktree add --quiet --detach "$scratch/checkout" "$candidate"
composer --working-dir="$scratch/checkout" archive --format=tar --dir="$scratch" --file=composer --no-plugins --no-scripts --no-interaction
git ls-tree -r --name-only "$candidate" -- src/ > "$scratch/source-files"

for producer in git composer; do
    archive_root="$scratch/$producer"
    mkdir "$archive_root"
    tar -xf "$scratch/$producer.tar" -C "$archive_root"
    for required in LICENSE README.md CHANGELOG.md SECURITY.md composer.json ELIGIBILITY_PACKAGE_REFERENCE.md docs/guides/USAGE_GUIDE.md llms.txt schema/eligibility_rules.sql CONTRIBUTING.md; do
        test -f "$archive_root/$required" || { echo "$producer archive missing $required" >&2; exit 1; }
    done
    for excluded in .git .gitignore .gitattributes .agents .github AGENTS.md .php-cs-fixer.dist.php docs/php-engineering-standards consumer-harness docker-compose.integration.yml tests tools vendor composer.lock phpstan.neon phpunit.xml.dist; do
        test ! -e "$archive_root/$excluded" || { echo "$producer archive includes $excluded" >&2; exit 1; }
    done
    (cd "$archive_root" && find src -type f | LC_ALL=C sort) > "$scratch/archive-source"
    LC_ALL=C sort "$scratch/source-files" > "$scratch/expected-source"
    diff -u "$scratch/expected-source" "$scratch/archive-source"
    while IFS= read -r path; do
        cmp "$scratch/checkout/$path" "$archive_root/$path"
    done < "$scratch/source-files"
    grep -Fq 'composer require maatify/php-eligibility:1.0.0-rc.3@RC maatify/php-persistence:1.0.0-rc.1@RC' "$archive_root/README.md"
    grep -Fxq '## [1.0.0-rc.3]' "$archive_root/CHANGELOG.md"
    grep -Fq 'This artifact targets `v1.0.0-rc.3`' "$archive_root/SECURITY.md"
    printf '%s archive PASS for %s (%s runtime files)\n' "$producer" "$candidate" "$(wc -l < "$scratch/source-files" | tr -d ' ')"
done
