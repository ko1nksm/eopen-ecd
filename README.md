# eopen (+ecd)

Open Explorer from WSL Terminal (plus PowerShell, Command Prompt).
Change directory of Terminal to Explorer location.

## Supported Windows and Terminals

* `Windows 10 64bit 1903` or later recommended,
* Probably works on `Windows 7` (include 32bit) or later.
* `WSL` / `WSL2` recommended for the terminal.
* Semi-support for `Powershell` and `Command Prompt`.

## Usage

### eopen

Open the file or change the directory from the Terminal via a shell (Explorer).

#### Examples

```
# Open directory with (latest used) Explorer
eopen ~/.config/

# Open directory with new instance of Explorer
eopen -n ~/.config/

# Opens with Windows default application
eopen image.png

# Opens with Windows text editor
eopen -e ~/.bashrc

# Use sudo to edit the unowned file
eopen -e --sudo /etc/hosts

# Opens with Windows default browser
eopen http://google.com

# Open other protocols
eopen mailto:user@example.com
eopen shell:downloads
eopen calculator:
eopen msnweather:
eopen ms-settings:
eopen xboxliveapp-1297287741: # Solitaire

# Open files and directories under Windows
eopen C:/Windows

# Open files and directories under Network shared folder
eopen //server/shared
```

**Note** If you use `eopen -e`, you need to set the execution path to
`EOPEN_EDITOR` environment variable for Windows  (not WSL).

**Note** `eopen` for PowerShell and Command Prompt are currently not
implemented. It just alias of `explorer.exe`.

### ewd

Print linux path of the (latest used) explorer location.

### ecd

Change the terminal directory to the (latest used) explorer location.

### epushd

Change the terminal directory to the (latest used) explorer location,
And add directories to stack. (Use `pushd` instead of `cd`.)

**Note** Not available on `ksh` and `mksh`, since `push` is not implemented.

## Download

**Download from [releases page](https://github.com/ko1nksm/eopen/releases)**

**Note** Highly recommend using x64 binary on Windows 10 64bit edition.
x86 binary is also work, but access to the WSL path (`\\wsl$\...`) from
32bit process is unstable. (Related? [issue 4260][4260] of microsoft/WSL)

[4260]: https://github.com/microsoft/WSL/issues/4260

**Note** It is also distributed for Windows 10 ARM / ARM64.
But I do not have those platforms. So it has not been tested at all.

## Installation

Extract the zip file to any directory and set to your shell's profile.

**Note** Require to enable `Launch folder windows in a separete process` in
*Explorer* -> *File* -> *Change folder and search options* -> *View*
-> *Advanced settings*.

### WSL terminal

Change the following line to the appropriate path and add it to your
shell's profile under your home directory.

#### For POSIX compliant shells

```sh
eval "$(sh "/path/to/eopen/init.sh")"
```

[Profile] **bash:** `.bashrc`, **zsh:** `.zshrc`, **ksh:** `.kshrc`,
**mksh:**, `.mkshrc`, **yash:** `.yashrc`

#### For tcsh

```sh
eval `sh "/path/to/eopen/init.sh" tcsh`
```

[Profile] **tcsh:** `.tcshrc`

#### For fish

```sh
eval (sh "/path/to/eopen/init.sh" fish)
```

[Profile] **fish:** `.config/fish/config.fish`

### PowerShell

Change the following line to the appropriate path and add it to your
PowerShell's profile.

```powershell
. "/path/to/eopen/init.ps1"
```

To edit profile, type `notepad $PROFILE` in PowerShell.


**Note** Require to change PowerShell execution policy.
(Google `Set-ExecutionPolicy`).

### Command prompt

Change the following line to the appropriate path and add it to `profile.bat`
(or favorite name)

```batch
@call \path\to\eopen\init.bat
```

Load it to Command Prompt. (For example, use `cmd /k profile.bat`)

## For developers

### Architecture

The `ebridge.exe` is helper module that operate shell (Explorer) via
COM Automation. All scripts are thin frontend of the `ebridge.exe`.

### How to build ebridge.exe

Require to install [Visual Studio 2019][vs2019] to build.
(Free Community Edition is enough.)

[vs2019]: https://visualstudio.microsoft.com/downloads/

To build, the following steps after installation of Visual Studio 2019

1. Run `Developer Command Prompt for VS 2019` from the *start menu*
2. Goto project root directory
3. Run `build.bat <TARGET...>` (TARGET: `x86`, `x64`, `arm`, `arm64`)
4. Generate archive files to the `dist` directory.

Or double click `ebridge.sln` in the [src](src) directory to launch Visual Studio IDE.

### Test

None, should be do.

## History

The formerly name of this project was `ecd` that was started to port
the `fcd` for macOS to Windows.

  * [fcd](http://www.script-factory.net/software/terminal/fcd/index.html) - Script factory
  * [fcd](https://qiita.com/Yuhsak/items/a1f154f14e5ff871b6d2) - another one-liner version

The core module was written with PowerShell script. Early version of
`ecd` and `eopen` were relies on the script. It was a bit slow (about 400ms-).
So I rewrote the core module as native by VC++.
And `eopen`, which has many features, has been changed to the main.

[CHANGELOG](CHANGELOG.md)

## License

MIT License
