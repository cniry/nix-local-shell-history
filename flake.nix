{
  description = "Project-local shell history helpers for Nix development shells";

  outputs =
    { self }:
    let
      defaultIgnoredDir = ".ignored";
      defaultZshDir = "zsh";
      defaultXdgDataDir = "xdg-data";

      bashHistoryShellHook =
        {
          projectRoot,
          ignoredDir ? defaultIgnoredDir,
          historyFile ? ".bash_history_nix_shell",
        }:
        ''
          mkdir -p "${projectRoot}/${ignoredDir}"
          export LOCAL_HISTFILE=1
          export BASH_NIX_SHELL_HISTFILE="${projectRoot}/${ignoredDir}/${historyFile}"
          export HISTFILE="$BASH_NIX_SHELL_HISTFILE"
        '';

      zshHistoryShellHook =
        {
          projectRoot,
          ignoredDir ? defaultIgnoredDir,
          historyFile ? ".zsh_history_nix_shell",
          zshDir ? defaultZshDir,
        }:
        ''
                    mkdir -p "${projectRoot}/${ignoredDir}/${zshDir}"
                    export LOCAL_HISTFILE=1
                    export NIX_SHELL_HISTFILE="${projectRoot}/${ignoredDir}/${historyFile}"
                    export ZDOTDIR="${projectRoot}/${ignoredDir}/${zshDir}"
                    cat > "$ZDOTDIR/.zshrc" <<'EOF'
          if [ -r "$HOME/.zshrc" ]; then
            source "$HOME/.zshrc"
          fi

          if [ -n "''${NIX_SHELL_HISTFILE:-}" ]; then
            export LOCAL_HISTFILE=1
            HISTFILE="$NIX_SHELL_HISTFILE"
            fc -p "$HISTFILE"
          fi
          EOF
                    if [ -n "''${ZSH_VERSION:-}" ]; then
                      export LOCAL_HISTFILE=1
                      HISTFILE="$NIX_SHELL_HISTFILE"
                      fc -p "$HISTFILE"
                    fi
        '';

      fishHistoryShellHook =
        {
          projectRoot,
          ignoredDir ? defaultIgnoredDir,
          xdgDataDir ? defaultXdgDataDir,
          historyName ? "nix_shell",
        }:
        ''
          mkdir -p "${projectRoot}/${ignoredDir}/${xdgDataDir}"
          export LOCAL_HISTFILE=1
          export XDG_DATA_HOME="${projectRoot}/${ignoredDir}/${xdgDataDir}"
          export fish_history="${historyName}"
        '';

      projectShellHistoryHook =
        {
          projectRoot,
          ignoredDir ? defaultIgnoredDir,
          bashHistoryFile ? ".bash_history_nix_shell",
          zshHistoryFile ? ".zsh_history_nix_shell",
          zshDir ? defaultZshDir,
          fishXdgDataDir ? defaultXdgDataDir,
          fishHistoryName ? "nix_shell",
        }:
        ''
          ${bashHistoryShellHook {
            inherit projectRoot ignoredDir;
            historyFile = bashHistoryFile;
          }}

          ${zshHistoryShellHook {
            inherit projectRoot ignoredDir zshDir;
            historyFile = zshHistoryFile;
          }}

          ${fishHistoryShellHook {
            inherit projectRoot ignoredDir;
            xdgDataDir = fishXdgDataDir;
            historyName = fishHistoryName;
          }}
        '';
    in
    {
      lib = {
        bash = bashHistoryShellHook;
        zsh = zshHistoryShellHook;
        fish = fishHistoryShellHook;
        all = projectShellHistoryHook;

        inherit
          bashHistoryShellHook
          zshHistoryShellHook
          fishHistoryShellHook
          projectShellHistoryHook
          ;
      };
    };
}
