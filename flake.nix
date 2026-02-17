{
  description = "A simple janet-nix project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    janet-nix = {
      url = "github:turnerdev/janet-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, janet-nix }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      packages = forAllSystems (system: {
        default = self.packages.${system}.boids;
        boids = janet-nix.packages.${system}.mkJanet rec {
          name = "boids";
          version = "0.0.1";
          src = ./.;
          quickbin = ./init.janet;
        };
        jfmt = janet-nix.packages.${system}.mkJanet rec {
          version = "0.0.1";
          name = "jfmt";
          src = builtins.fetchGit {
            url = "https://github.com/andrewchambers/jfmt.git";
            rev = "b27dff6bb32b89b20462eec33f50c1583c301b0a";
          };
          quickbin = "./jfmt.janet";
        };
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.boids);

      hydraJobs = forAllSystems (system: {
        build = self.packages.${system}.default;

        test-suite = nixpkgs.legacyPackages.${system}.runCommand "judge" { } ''
          ${self.packages.${system}.default}/bin/boids --help > $out
          echo "Binary executed successfully" >> $out
        '';
      });

      devShell = forAllSystems (system:
        with nixpkgsFor.${system};
        let
          jfmt = self.packages.${system}.jfmt;
          libPath = with pkgs;
            lib.makeLibraryPath [
              libGL
              libxkbcommon
              wayland
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr
            ];

        in mkShell {
          LD_LIBRARY_PATH = libPath;
          packages = [
            janet
            jpm
            jfmt
            raylib
            libGL
            xorg.libX11
            xorg.libXrandr
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
          ];
          buildInputs = [ janet ];
          shellHook = ''
            # localize jpm dependency paths
            export JANET_PATH="$PWD/.jpm"
            export JANET_TREE="$JANET_PATH/jpm_tree"
            export JANET_LIBPATH="${pkgs.janet}/lib"
            export JANET_HEADERPATH="${pkgs.janet}/include/janet"
            export JANET_BUILDPATH="$JANET_PATH/build"
            export PATH="$PATH:$JANET_TREE/bin"
            export PATH="$PATH:${libPath}"
            mkdir -p "$JANET_TREE"
            mkdir -p "$JANET_BUILDPATH"
          '';
        });
    };
}
