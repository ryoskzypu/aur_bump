# aur_bump

GitHub workflow that runs weekly and does the following:

- Fetches all AUR packages from specific maintainer.
- Clones every pkg and fetches the current upstream pkg version with `nvchecker` to compare against `PKGBUILD`'s `pkgver`.
- Creates/updates repo issues when pkgs are out-of-date or need `epoch`.
- Closes existing issues when pkgs are up-to-date.

Based on Arch's [`pkgctl version check`](https://gitlab.archlinux.org/archlinux/devtools/-/blob/master/src/lib/version/check.sh)
and [Bumpbuddy](https://gitlab.archlinux.org/archlinux/bumpbuddy).

> [!NOTE]
> To get notifications on issues, a [GitHub App](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps) is required.

## See also

- https://wiki.archlinux.org/title/Creating_packages#New_upstream_releases
- https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/making-authenticated-api-requests-with-a-github-app-in-a-github-actions-workflow
