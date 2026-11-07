# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `lien` input: optional `google_resource_manager_lien` restricting
  `resourcemanager.projects.delete`, so the project cannot be deleted from the
  console, `gcloud` or the API while the lien exists. `origin` defaults to
  `"terraform"`. Null by default, so existing plans do not change.
- `lien_name` output.

### Changed

- CI: bump actions to their current majors, pin tool versions, and restrict the
  workflow token to `contents: read`.
- CI: add Dependabot for GitHub Actions and the Terraform provider.
- Docs: pin the README usage `source` to a release tag; fix the LICENSE year.

## [1.0.0]

Initial release (`v0.1.0` points at the same commit).

[Unreleased]: https://github.com/moveeeax/terraform-google-project/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/moveeeax/terraform-google-project/releases/tag/v1.0.0
