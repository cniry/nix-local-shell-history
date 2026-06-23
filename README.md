# nix-local-shell-history

Small Nix flake helper that gives each project its own shell history files inside a local ignored directory.

It is useful when entering a development shell and then starting another shell, for example:

```sh
nix-shell --command zsh
```

Some shells, especially zsh, may reset history paths while loading their normal startup files. This helper keeps project-local history active after that startup logic runs.

## Installation

Add this flake to your project's `flake.nix` inputs:

```nix
{
  inputs.local-history.url = "github:cniry/nix-local-shell-history";
}
```

Then update the lock file:

```sh
nix flake lock
```

After that, pass `local-history` into your `outputs` and use one of the helpers in your development shell's `shellHook`.

## Usage

Example `flake.nix`:

```nix
{
  inputs.local-history.url = "github:cniry/nix-local-shell-history";

  outputs =
    {
      nixpkgs,
      local-history,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.gnumake
        ];

        shellHook = local-history.lib.all {
          projectRoot = toString ./.;
        };
      };
    };
}
```

By default the helper stores history under:

```text
.ignored/
```

It also exports:

```sh
LOCAL_HISTFILE=1
```

That can be used by shell startup files or prompts to detect that project-local history is active.

Add `.ignored` to the consuming project's `.gitignore`.

## Helpers

### All supported shells

```nix
local-history.lib.all {
  projectRoot = toString ./.;
}
```

This sets up project-local history for bash, zsh, and fish.

### Bash only

```nix
local-history.lib.bash {
  projectRoot = toString ./.;
}
```

Default history path:

```text
.ignored/.bash_history_nix_shell
```

### Zsh only

```nix
local-history.lib.zsh {
  projectRoot = toString ./.;
}
```

Default history path:

```text
.ignored/.zsh_history_nix_shell
```

The zsh helper sets a project-local `ZDOTDIR`, creates a small `.zshrc`, sources the user's normal `$HOME/.zshrc`, and then restores the project-local `HISTFILE`.

### Fish only

```nix
local-history.lib.fish {
  projectRoot = toString ./.;
}
```

Default fish history location:

```text
.ignored/xdg-data/fish/nix_shell_history
```

## Options

```nix
local-history.lib.all {
  projectRoot = toString ./.;
  ignoredDir = ".ignored";
  bashHistoryFile = ".bash_history_nix_shell";
  zshHistoryFile = ".zsh_history_nix_shell";
  zshDir = "zsh";
  fishXdgDataDir = "xdg-data";
  fishHistoryName = "nix_shell";
}
```

The longer names `projectShellHistoryHook`, `bashHistoryShellHook`, `zshHistoryShellHook`, and `fishHistoryShellHook` are still available as aliases.

The helper does not import or pin `nixpkgs`; it only returns `shellHook` fragments.
