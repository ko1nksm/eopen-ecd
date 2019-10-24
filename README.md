# ecd & eopen

Change directory to each other between Terminal and Explorer.

## Usage

`ecd` - Change the terminal directory to the current explorer location.

```
Usage: ecd
```

`eopen` - Open the file or change the directory from the terminal via a shell (explorer).

```
Usage: eopen [-e | -n] [file | directory | protocol]

examples
  eopen                     # Open the current directory in explorer.
  eopen /etc/               # Open the specified directory in explorer.
  eopen -n /etc/            # Open the specified directory in new instance of explorer.
  eopen ~/image.jpg         # Open the file in associated application.
  eopen -e /etc/hosts       # Open the file in text editor ($EOPEN_EDITOR).
  eopen http://google.com   # Open the url in default browser.

  The path of file or directory allows linux and windows path.
  (e.g. /etc/hosts, C:/Windows/System32/drivers/etc/hosts)
```

**Note** Require to enable `Launch folder windows in a separete process` in *Explorer* -> *File* -> *Change folder and search options* -> *View* -> *Advanced settings*.

### WSL terminal

Define alias refer to the following and type `ecd`.

**Note** If you use `eopen -e`, you need to set the execution path to `EOPEN_EDITOR` environment variable.

#### For sh

`bash`, `zsh`, `ksh` and compatibile shells.

```sh
alias ecd='eval "$(/path/to/ecd.sh)"'
alias eopen='/path/to/eopen.sh'
```

#### For tcsh

```sh
alias ecd 'eval `/path/to/ecd.sh`'
alias eopen '/path/to/eopen.sh'
```

#### For fish

```sh
alias ecd='eval (/path/to/ecd.sh)'
alias eopen='/path/to/eopen.sh'
```

### Command prompt

Type `ecd` (`ecd.bat`) or `epushd` (`epushd.bat`).

**Note** `epushd.bat` uses `pushd` command instead of `cd`. So you can restore directory by `popd` and use UNC path.

### PowerShell

**Note** Require to change execution policy. (Google `Set-ExecutionPolicy`).

Add the following code to your profile (Run `notepad $profile` to edit) and type `ecd`.

```powershell
function ecd {
  $ewd = "/path/to/ewd.ps1"
  cd (powershell $ewd).TrimEnd("`r?`n")
}
```

## Thanks

[fcd](https://qiita.com/Yuhsak/items/a1f154f14e5ff871b6d2) (macOS version of this. The idea was taken from here).

## License

MIT License
