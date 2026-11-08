{ config, lib, pkgs, ... }:
let
  cfg = config.programs.use-env;
  use-env = pkgs.writeShellApplication {
    name = "use-env";
    runtimeInputs = [ pkgs.git pkgs.direnv ];
    text = ''
      envs_dir=${lib.escapeShellArg cfg.envsDir}

      if [ $# -ne 1 ]; then
        echo "usage: use-env <env>" >&2
        echo "available:" >&2
        for d in "$envs_dir"/*/flake.nix; do
          [ -e "$d" ] && basename "$(dirname "$d")" >&2
        done
        exit 1
      fi

      dir="$envs_dir/$1"
      if [ ! -f "$dir/flake.nix" ]; then
        echo "use-env: no such env: $1 ($dir/flake.nix missing)" >&2
        exit 1
      fi

      exclude="$(git rev-parse --git-path info/exclude)"
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
