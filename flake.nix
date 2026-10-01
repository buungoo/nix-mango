{
  description = "Bungos mango desktop";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.mangowm = {
    url = "github:buungoo/mango/feat/ignore-fullscreen";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.vicinae = {
    url = "github:vicinaehq/vicinae";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.wshowkeys = {
    url = "github:DreamMaoMao/wshowkeys";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    # mango is a Wayland compositor, so it is linux only.
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"];
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
  in {
    wrapperModules = {
      mango = module;
      default = self.wrapperModules.mango;
    };
    wrappers = {
      mango = wrapper.config;
      default = self.wrappers.mango;
    };
    overlays = {
      mango = final: prev: {mango = self.wrappers.mango.wrap {pkgs = final;};};
      default = self.overlays.mango;
    };
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        mango = self.wrappers.mango.wrap {inherit pkgs;};
        default = self.packages.${system}.mango;
      }
    );
    nixosModules = {
      default = self.nixosModules.mango;
      # mango's own module (session, portals, polkit, xwayland), wrapped package as default
      mango = {
        pkgs,
        lib,
        ...
      }: {
        imports = [inputs.mangowm.nixosModules.mango];
        programs.mango.package = lib.mkDefault (self.wrappers.mango.wrap {inherit pkgs;});

        # features/recording needs the setcap'd gsr-kms-server to capture a
        # monitor.
        programs.gpu-screen-recorder.enable = true;

        # wshowkeys reads /dev/input, so it needs setuid, which the store cannot
        # carry. The fork's own module is nested under eachDefaultSystem, so it
        # is not a usable NixOS module.
        security.wrappers.wshowkeys = {
          setuid = true;
          owner = "root";
          group = "root";
          source = lib.getExe inputs.wshowkeys.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      };
    };

    # For development of this package
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            just
            nixd
            alejandra
          ];
        };
      }
    );
  };
}
