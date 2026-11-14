# DEC-006 — Shared Persistence RC trial

## Decision Metadata

| Field | Value |
|---|---|
| Decision ID | DEC-006 |
| Title | Shared Persistence RC trial |
| Status | ACTIVE |
| Scope / Concern | PDO transactions and pagination |
| Decision Authority / Deciders | Project Owner via the adopted shared Persistence direction and authorization to migrate this package |
| Canonical Contract / Current Owner | [Package Reference](../../ELIGIBILITY_PACKAGE_REFERENCE.md) |

## Context

Eligibility used the legacy shared Persistence package for pagination and
transaction management. The adopted package-building standard permits
temporary testing against the newest published replacement RC.

## Decision

Use `maatify/php-persistence` at exactly `1.0.0-rc.1` in the checkout,
with Composer's global minimum stability kept at `stable`.
Use the shared API for pagination and savepoints on the same Host PDO.
Direct callers adopt the new shared types. Published Eligibility
`v1.0.0-rc.2` retains its original dependency and API.

## Consequences

A checkout consumer must explicitly allow the Persistence RC in its root
Composer project. A Stable Eligibility release requires a compatible Stable
Persistence dependency and fresh verification. An Eligibility RC using this
dependency requires separate release authorization and published-artifact
verification.
