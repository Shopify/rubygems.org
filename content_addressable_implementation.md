# Content Addressable Gems — Server-Side Implementation Plan

## Overview

This document describes the server-side changes made to RubyGems.org to support content-addressable gems ("skinny binaries"). The goal is to allow gem authors to push multiple pre-compiled binary gems for the same name, version, and platform — each targeting a specific Ruby minor version — instead of bundling all `.so` files into a single "fat binary" gem.

## Scope

Server-side changes only. This does not cover client-side (RubyGems/Bundler) changes, gem publisher tooling, or the `bundle install --local` stub specification changes described in the proposal.

### What was implemented

1. **Skinny binary detection heuristic** on the `Version` model
2. **Relaxed uniqueness constraints** to allow multiple skinny binaries per `(name, version, platform)`
3. **Duplicate minor version guard** — only one skinny binary per Ruby minor version
4. **Content-addressable gem storage** — skinny binaries stored as `name-version-sha10.gem` on S3
5. **V2 compact index endpoint** (`/v2/info/:gem_name`) with `platform:` in requirements
6. **V1 compact index filtering** — skinny binaries excluded for backward compatibility
7. **Cache invalidation** for the v2 compact index
8. **UI change** — Ruby version displayed next to platform for skinny binaries

## Key Decisions

### 1. No explicit `content_addressable` database column

We considered adding a boolean `content_addressable` column to the `versions` table to explicitly mark skinny binaries. Instead, we infer the classification at runtime using a heuristic based on `required_ruby_version`.

**Why:** The distinction between fat and skinny is not an intrinsic property of the gem — it's a consequence of how broad the Ruby version requirement is. Adding a column would require a migration and introduce state that could get out of sync with reality. The heuristic is deterministic and derived from existing data.

**Trade-off:** The heuristic involves parsing `Gem::Requirement` strings and testing against a range of Ruby minor versions (2.0–4.9). This is a small computation but happens at query time in `GemInfo`. Since compact index responses are cached in Memcached, the cost is amortized.

### 2. Skinny binary = targets exactly one Ruby minor version

A gem is classified as a "skinny binary" if:
- It has a platform (i.e., `platform != "ruby"`)
- Its `required_ruby_version` satisfies exactly **one** Ruby minor version (e.g., `3.4`)

We test against `MAJOR.MINOR.0` versions from 2.0 through 4.9. If exactly one matches, it's skinny.

**Examples:**
| `required_ruby_version` | Classification | Reason |
|---|---|---|
| `~> 3.4.0` | Skinny | Matches only `3.4.0` |
| `>= 3.4.0, < 3.5.0` | Skinny | Matches only `3.4.0` |
| `>= 3.2, < 4.1.dev` | Fat | Matches `3.2.0`, `3.3.0`, `3.4.0`, `4.0.0` |
| `>= 0` | Fat | Matches everything |
| (blank/nil) | Fat | No requirement = not skinny |

**Note on patch versions:** `>= 3.4.0, < 3.5.0` covers many patch versions (3.4.0, 3.4.1, etc.) but only one **minor** version (`3.4`). This is correctly classified as skinny because the `.so` file inside targets one Ruby minor ABI.

### 3. One fat binary allowed per (name, version, platform)

The existing uniqueness constraint (`platform_and_number_are_unique`) is preserved for fat binaries. Only skinny binaries skip this check, and they get their own duplicate guard (see below).

### 4. Duplicate minor version prevention

Two skinny binaries for the same `(name, version, platform)` targeting the same Ruby minor version are **not** allowed. This is enforced in two places:

- **`Pusher#find`** — early rejection during gem push, using `Version.targeted_ruby_minor_version` to semantically compare minor versions
- **`Version#platform_and_number_are_unique` validation** — DB-level safety net

The comparison is semantic, not string-based. `~> 3.4.0` and `>= 3.4.0, < 3.5.0` both resolve to minor version `"3.4"` and would be detected as duplicates.

## Files Changed

### `app/models/version.rb`

- **`RUBY_MINOR_VERSIONS`** — constant with `Gem::Version` objects for `2.0.0` through `4.9.0`
- **`Version.targets_single_ruby_minor_version?(str)`** — class method, returns true if the requirement covers exactly one minor version
- **`Version.targeted_ruby_minor_version(str)`** — class method, returns the minor version string (e.g., `"3.4"`) or nil
- **`skinny_binary?`** — instance method, true if platformed + targets single minor
- **`sha256_short`** — first 10 hex characters of sha256, used in content-addressable filenames
- **`gem_file_name`** — returns `name-version-sha10.gem` for skinny binaries, `full_name.gem` otherwise
- **`full_nameify!`** — uses sha instead of platform for skinny binaries
- **`platform_and_number_are_unique`** — skinny binaries skip the old check, get duplicate minor version guard instead
- **`gem_platform_and_number_are_unique`** — skipped for skinny binaries
- **`unique_canonical_number`** — skipped for skinny binaries (they share canonical numbers)
- **`skinny_binary_duplicate_minor_version?`** — private helper that queries existing versions to detect duplicate minor versions

### `app/models/pusher.rb`

- Sets `required_ruby_version` on the version early in `find` so `skinny_binary?` works before `update_attributes_from_gem_specification!`
- Allows pushing when existing versions share `(number, platform)` if the new gem is a skinny binary targeting a different minor version
- Blocks push if a skinny binary for the same minor version already exists
- Skips `full_name == spec.original_name` validation for skinny binaries (since `full_name` now includes sha)

### `app/models/gem_info.rb`

- **`compact_index_info_v2`** — new public method with caching under `info_v2/#{gem_name}`
- **`compute_compact_index_info`** (v1) — filters out skinny binaries using `Version.targets_single_ruby_minor_version?`
- **`compute_compact_index_info_v2`** — checks the stored `full_name` to determine if each version is content-addressable; if so, uses sha-based identifier with `platform:` requirement; old-style platformed gems keep platform-based identifiers
- Extracted `parse_dependencies`, `base_query`, `v1_requirements_and_dependencies`, and `v2_requirements_and_dependencies` helpers; v2 query includes `full_name` in the GROUP BY

### `app/controllers/api/compact_index_controller.rb`

- **`info_v2`** action — serves the v2 compact index format, mirrors `info` but calls `compact_index_info_v2`
- `before_action :find_rubygem_by_name` extended to include `info_v2`

### `config/routes.rb`

- Added `GET /v2/info/:gem_name` → `api/compact_index#info_v2`

### `lib/compact_index/gem_version.rb` (vendored)

- Added `platform_requirement` field to `CompactIndex::GemVersion` struct
- `to_line` appends `,platform:= <platform_requirement>` when the field is set

### `lib/gem_cache_purger.rb`

- Added `info_v2/#{gem_name}` to the list of cache keys purged on gem push/yank

### `app/views/versions/_version.html.erb`

- For skinny binaries, displays `(Ruby ~> 3.4.0)` next to the platform name

## Compact Index Response Format

### V1 (`/info/:gem_name`) — unchanged for old clients

Skinny binaries are **excluded**. Old clients only see source gems and fat binaries:

```
2.9.0 mini_portile2:~> 2.8.0|checksum:fbc1234567...,ruby:>= 3.2.0
2.9.0-x86_64-linux-musl |checksum:ef716ba7a6...,ruby:< 4.1.dev&>= 3.2,rubygems:>= 3.3.22
```

### V2 (`/v2/info/:gem_name`) — content-addressable

All versions included. **New platformed gems** (pushed after this change) use sha-based identifiers with `platform:` in requirements. **Old platformed gems** (pushed before this change) keep platform-based identifiers. Source gems are unchanged.

Example with a mix of old and new:

```
2.9.0 mini_portile2:~> 2.8.0|checksum:fbc1234567...,ruby:>= 3.2.0
2.9.0-x86_64-linux-musl |checksum:ef716ba7a6...,ruby:< 4.1.dev&>= 3.2,rubygems:>= 3.3.22
2.10.0-ef716ba7a6 |checksum:ef716ba7a6...,ruby:< 4.1.dev&>= 3.2,rubygems:>= 3.3.22,platform:= x86_64-linux-musl
2.10.0-abc1234567 |checksum:abc1234567...,ruby:~> 3.2.0,rubygems:>= 3.3.22,platform:= x86_64-linux-musl
2.10.0-1bc1234567 |checksum:1bc1234567...,ruby:~> 3.3.0,rubygems:>= 3.3.22,platform:= x86_64-linux-musl
2.10.0-12c1234567 |checksum:12c1234567...,ruby:~> 3.4.0,rubygems:>= 3.3.22,platform:= x86_64-linux-musl
```

The format is determined by checking the stored `full_name` in the database: if it ends with the platform string, it's old-style; if it ends with a sha prefix, it's content-addressable.

## Open Questions / Future Work

### Mixed format in v2 compact index requires two client code paths

The v2 compact index currently serves a mix of old-style (platform-based) and new-style (sha-based) entries for platformed gems. Old gems pushed before this change keep platform identifiers, new gems get sha identifiers with `platform:` in requirements.

This means a v2 client needs two code paths:
- **No `platform:` requirement** → old-style: use the version-platform field for both platform matching and filename construction
- **Has `platform:` requirement** → new-style: use `platform:` for platform matching, use the version-platform field (which is the sha) for filename construction

To simplify the client to a single code path, we'd need all v2 entries to use sha-based identifiers. This would require either re-uploading old gems to S3 with sha-based filenames, or adding a CDN redirect from `gems/name-version-sha10.gem` to `gems/name-version-platform.gem` for old gems.

### Relaxing the database uniqueness constraint

The `full_name` column has a uniqueness constraint in the database. For skinny binaries, `full_name` now includes the sha (e.g., `sqlite3-2.9.0-abc1234567`), so this naturally avoids collisions. However, we should audit any database indexes or constraints that assume `(rubygem_id, number, platform)` is unique and consider whether a migration is needed to formally relax them.

### Fat + skinny coexistence and resolver behavior

The proposal mentions that fat and skinny binaries can coexist in the v2 index. We have not yet investigated whether Bundler/RubyGems resolvers will naturally prefer a more specific version requirement (skinny) over a broader one (fat). This needs investigation on the client side.


