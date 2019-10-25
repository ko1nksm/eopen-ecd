# ecd & eopen

Change directory to each other between Terminal and Explorer.

## Usage

**Note** Require to enable `Launch folder windows in a separete process` in *Explorer* -> *File* -> *Change folder and search options* -> *View* -> *Advanced settings*.

`ecd` - Change the terminal directory to the current explorer location.

```
Usage: ecd
```


`ewd` - Display linux path of current explorer location.

```
Usage: ewd
```

`eopen` - Open the file or change the directory from the terminal via a shell (explorer).

```
Usage: eopen [options] [file | directory | uri]

options:
  -e, --editor      Open the file in text editor ($EOPEN_EDITOR)
  -n, --new         Open the specified directory in new instance of explorer
      --sudo        Use sudo to write the unowned file
  -v, --version     Display the version
  -h, --help        You're looking at it

note:
  The file or the directory allows linux and windows path.
  (e.g. /etc/hosts, C:/Windows/System32/drivers/etc/hosts)

  The uri must start with protocol schema. (e.g http:, https:)
```

### WSL terminal

Define alias refer to the following and type `ecd`.

**Note** If you use `eopen -e`, you need to set the execution path to `EOPEN_EDITOR` environment variable.

#### For sh

`bash`, `zsh`, `ksh` and compatibile shells.

```sh
alias ecd='eval "$(/path/to/ecd.sh)"'
alias ewd='/path/to/ewd.sh'
alias eopen='/path/to/eopen.sh'
```

#### For tcsh

```sh
alias ecd 'eval `/path/to/ecd.sh`'
alias ewd '/path/to/ewd.sh'
alias eopen '/path/to/eopen.sh'
```

#### For fish

```sh
alias ecd='eval (/path/to/ecd.sh)'
alias ewd='/path/to/ewd.sh'
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

## Changelog

* 0.1.0 First version
* 0.2.0 eopen: Add --sudo option

## Thanks

[fcd](https://qiita.com/Yuhsak/items/a1f154f14e5ff871b6d2) (macOS version of this. The idea was taken from here).

## License

MIT License
