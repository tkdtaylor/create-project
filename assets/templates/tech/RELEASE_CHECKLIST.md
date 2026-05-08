# Release checklist

Use this as the gate before tagging any `v*.*.*` release. Most of it is automated under `make release-check`; the manual items are explicit.

## Pre-flight

- [ ] On `main`: `git checkout main && git pull --ff-only`
- [ ] Working tree is clean: `git status` shows nothing
- [ ] Version bumped in the project manifest (`pyproject.toml`, `Cargo.toml`, `package.json`, `go.mod`, etc.)
- [ ] `CHANGELOG.md` has an entry for the new version under a dated header (move items from `[Unreleased]`)

## Automated verification

```bash
make release-check
```

Stages, in order:

1. `make check` — lint + typecheck + unit tests
2. `make fitness` — architectural invariants from `docs/spec/fitness-functions.md`
3. *(optional)* end-to-end smoke / demo against a real built artifact
4. *(optional)* every published example exits 0 in offline mode (catches example bit-rot)

A failing stage prints which one failed and the recipe exits non-zero. Do not proceed past a failure.

## Manual verification

- [ ] `git log --oneline main..` against the previous tag — no commits you don't recognize
- [ ] `LICENSE` and any security-related docs unchanged (or, if intentional, captured in CHANGELOG)
- [ ] No real secrets / API keys in the diff: `git diff <prev-tag>..main | grep -E 'AKIA[A-Z0-9]{16}|sk-[A-Za-z0-9-]{20,}'` returns nothing
- [ ] Eyeball any new public surface: README install/usage instructions still match what ships

## Tag and push

```bash
VERSION=v0.X.Y  # match the manifest
git tag -a "$VERSION" -m "<project> $VERSION"
git push origin "$VERSION"
```

## Post-tag

- [ ] Release workflow ran and succeeded (`gh run list --workflow release.yml -L 1` or the Actions tab)
- [ ] Published artifact landed at the configured registry (`crates.io`, `npmjs.com`, `pypi.org`, `ghcr.io`, etc.) — if applicable
- [ ] CHANGELOG `[Unreleased]` section reset to empty/template

## If something goes wrong

- A failing `make release-check` stage is the first signal. Read its output, fix the underlying issue (do not bypass), and re-run.
- A failing post-tag workflow can usually be re-run from the GitHub Actions UI without re-tagging — make workflows idempotent so this stays safe.
- If the tag itself was wrong (e.g. wrong version), delete it both locally and on the remote *before* the post-tag workflows publish, then re-tag:
  ```bash
  git tag -d v0.X.Y
  git push origin :refs/tags/v0.X.Y
  ```
