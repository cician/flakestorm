{
  description = "Flake Storm - NixOS flake micro-vm manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.flakestorm = self.packages.x86_64-linux.default;

    packages.x86_64-linux.default = 
      let pkgs = nixpkgs.legacyPackages.x86_64-linux; 
      in pkgs.stdenv.mkDerivation {
        pname = "flakestorm";
        version = "1.0";
        src = ./.;
        installPhase = ''
          mkdir -p $out/bin
          cp bin/flakestorm $out/bin/flakestorm
          chmod +x $out/bin/flakestorm
        '';
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.default;
  };
}
