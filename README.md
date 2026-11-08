# envs

Shared dev environments (nix flakes), used without touching project repos.

## Usage

In the project root:

```sh
use-env haskell
```

Writes `.envrc` (`use flake ~/envs/haskell`), adds `.envrc` and `.direnv` to `.git/info/exclude` (no duplicates), and runs `direnv allow`.

## Install (home-manager)

```nix
# flake inputs
inputs.envs.url = "git+file:///Users/<you>/envs";

# home-manager config
imports = [ inputs.envs.homeManagerModules.default ];
programs.use-env.enable = true;
# programs.use-env.envsDir = "/path/to/envs";  # default: ~/envs
```

## Manual (without the module)

```sh
echo "use flake ~/envs/haskell" > .envrc && printf ".envrc\n.direnv\n" >> .git/info/exclude && direnv allow
```
