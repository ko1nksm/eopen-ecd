# Changelog

## Unreleased
## 0.12.0 - 2020-01-13
### Changed
- eopen: Use `-S` or `--web-search` for web search instead of `-s`, `--search`
### Added
- eopen: Add support for windows explorer search (`-s`, `--search`)

## 0.11.0 - 2020-01-12
### Added
- eopen: Added `--search` option to search in browser

## 0.10.3 - 2020-01-11
### Fixed
- Fixed an issue when opening URL containing query string

## 0.10.2 - 2019-11-19
### Fixed
- Added missing file to the distribution package

## 0.10.1 - 2019-11-15
### Added
- Added `-0`, option for `elsi`
### Fixed
- Various bug fixes for PowerShell and Command Prompt

## 0.10.0 - 2019-11-14
### Added
- Support cygwin, msys2 and git bash
- Added `-u`, `-w`, `-m` option for `ewd`
- Added `elsi` command to list selected items
### Fixed
- Fixed broken `ecd`, `epush` for tcsh

## 0.9.1 - 2019-11-10
### Changed
- Do sudo first one time only with `eopen -e --sudo`
### Fixed
- Fixed path handling for command prompt
- Various bug fixes

## 0.9.0 - unreleased
### Added
- Implemented `eclose`, `epopd`
- Added `EOPEN_LAUNCH_TO` environment variable
- Add supports `~~` (Windows home) directory (WSL only)
- eopen: Add `--background` option
### Changed
- `ecd` / `epushd` changes to behave like `cd` / `pushd`
- Only show `eopen` with not arguments
- `eopen` with no arguments only display instead of opening the current directory

## 0.8.0 - 2019-11-03
### Changed
- Windows native implementation
- Improve perfomance

## Before 0.8.0
- Slow PowerShell implementation version
