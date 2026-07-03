# Changelog

All notable changes to create-project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

create-project has not yet cut a tagged release. The scaffold (project
workspace generation, existing-codebase adoption, skill sync, project audit),
the template set under `assets/templates/`, and the hook/agent tooling are
developed on `main`. The first tagged release will populate this section.

### Added

- SECURITY policy, contribution guide, code of conduct, and this changelog.
- A SECURITY.md starter template in the scaffold's tech template set.

### Changed

- dep-scan install guidance now recommends download-review-run (or checksum
  verification) instead of piping curl straight to bash.
