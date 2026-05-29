# aur_bump

GitHub workflow that runs weekly and does the following:

- Fetches all AUR packages from specific maintainer.
- Clones every pkg, then fetches the current upstream pkg version with `nvchecker`
  to compare against `PKGBUILD`s `pkgver`.
- Notifies the repo owner when pkgs are out-of-date.
