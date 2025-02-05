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

    nixosModules.flakestorm = { config, lib, pkgs, ... }: {
      options.services.flakestorm = {
        enable = lib.mkEnableOption "Flake Storm Service";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.bash;
          description = "The package providing the flakestorm executable";
        };
      };

      config = lib.mkIf config.services.flakestorm.enable {
        systemd.services.flakestorm = {
          description = "Flakestorm Service";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${config.services.flakestorm.package}/bin/bash -c 'echo Flakestorm running'";
            Restart = "always";
          };
        };
      };
    };

  };
}
