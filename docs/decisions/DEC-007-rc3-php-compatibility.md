# DEC-007 — PHP compatibility boundary for RC.3

## Decision Metadata

| Field | Value |
|---|---|
| Decision ID | DEC-007 |
| Title | PHP compatibility boundary for RC.3 |
| Status | ACTIVE |
| Scope / Concern | Composer runtime and CI |
| Decision Authority / Deciders | Project Owner, who approved a new RC to update the Composer requirement |
| Canonical Contract / Current Owner | [Composer manifest](../../composer.json) |

## Context

Published RC.2 used the Composer constraint `^8.4`. The adopted standard
defines separate security patch floors for PHP 8.4 and 8.5.

## Decision

Use `>=8.4.27 <8.5.0 || >=8.5.12 <8.6.0` for the planned RC.3 and set
Composer's resolution platform to the lowest accepted patch, PHP 8.4.27.

## Consequences

Hosts below either patch floor must upgrade PHP to install RC.3. Later PHP
minors require fresh qualification and a compatibility update.
