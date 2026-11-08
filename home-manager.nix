{ config, lib, pkgs, ... }:
let
  cfg = config.programs.use-env;
  use-env = pkgs.writeShellApplication {
    name = "use-env";
    runtimeInputs = [ pkgs.git pkgs.direnv ];
    text = ''
      envs_dir=${lib.escapeShellArg cfg.envsDir}

      usage() {
        echo "usage: use-env <env>      set up .envrc for <env>" >&2
        echo "       use-env --remove   undo it" >&2
        echo "available:" >&2
        for d in "$envs_dir"/*/flake.nix; do
          [ -e "$d" ] && basename "$(dirname "$d")" >&2
        done
        exit 1
      }

      [ $# -eq 1 ] || usage

      exclude="$(git rev-parse --git-path info/exclude)"

      if [ "$1" = "--remove" ]; then
        if [ -f .envrc ]; then
          if ! grep -q "^use flake $envs_dir/" .envrc; then
            echo "use-env: .envrc was not created by use-env, leaving it alone" >&2
            exit 1
          fi
          direnv deny
          rm .envrc
        fi
        rm -rf .direnv
        if [ -f "$exclude" ]; then
          tmp="$(mktemp)"
          grep -vxF -e .envrc -e .direnv "$exclude" > "$tmp" || true
          cat "$tmp" > "$exclude"
          rm "$tmp"
        fi
        exit 0
      fi

      case "$1" in -*) usage ;; esac

      dir="$envs_dir/$1"
      if [ ! -f "$dir/flake.nix" ]; then
        echo "use-env: no such env: $1 ($dir/flake.nix missing)" >&2
        exit 1
      fi

      mkdir -p "$(dirname "$exclude")"
      for p in .envrc .direnv; do
        grep -qxF "$p" "$exclude" 2>/dev/null || echo "$p" >> "$exclude"
      done

      echo "use flake $dir" > .envrc
      direnv allow
    '';
  };
in
{
  options.programs.use-env = {
    enable = lib.mkEnableOption "use-env: write .envrc pointing at a shared dev env flake";
    envsDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/envs";
      description = "Directory containing env flakes (one subdirectory per env).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ use-env ];
  };
}
