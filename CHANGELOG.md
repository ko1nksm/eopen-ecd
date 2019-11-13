# Changelog

## Unreleased
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
