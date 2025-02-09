{
  description = "Flake Storm - NixOS flake micro-vm manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, microvm }: {
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
          cp bin/flakestormd $out/bin/flakestormd
          chmod +x $out/bin/flakestorm
          chmod +x $out/bin/flakestormd
        '';
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.default;
    
    #nixosModules.microvm = microvm.nixosModules.host;

    # Include the microvm host module
    # https://astro.github.io/microvm.nix/host.html
    microvm = microvm.nixosModules.microvm;
    microvm_host = microvm.nixosModules.host;

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
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${config.services.flakestorm.package}/bin/flakestormd";
            Restart = "always";
          };
        };

        # Enable required host features for microvm like virtiofsd and advanced networking.
        microvm.host.enable = true;

        # try to automatically start these MicroVMs on bootup
        #microvm.autostart = [
        #  "flakestorm-selfdev"
        #];

      };
    };

  };
}
