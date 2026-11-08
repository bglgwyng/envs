{
  outputs = { self }: {
    homeManagerModules.default = import ./home-manager.nix;
  };
}
