# Package Manifests

The package manifests describe the intended system. They are separate from the observed package snapshots under `docs/baseline/`.

## Files

- `official.txt` is the desired list of explicitly installed packages available from configured official repositories.
- `aur.txt` is the reviewed list of desired foreign packages, including AUR packages when applicable.

Phase 1 will populate both manifests after each package has a documented purpose. A foreign package is not assumed to come from the AUR until its source is verified.

Manifest readers must ignore blank lines and lines beginning with `#`. Package entries use one package name per line and remain sorted.
