{
  description = "A simple janet-nix project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    jaylib-src = {
      url = "github:janet-lang/jaylib";
      flake = false;
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      jaylib-src,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        default = self.packages.${system}.boids;

        boids = nixpkgsFor.${system}.stdenv.mkDerivation {
          pname = "boids";
          version = "0.0.1";
          src = ./.;

          buildInputs = with nixpkgsFor.${system}; [
            janet
            jpm
            raylib
            libGL
            xorg.libX11
            xorg.libXrandr
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
          ];

          buildPhase = ''
            export JANET_PATH="$PWD/.jpm"
            export JANET_TREE="$JANET_PATH/jpm_tree"
            export JANET_LIBPATH="${nixpkgsFor.${system}.janet}/lib"
            export JANET_HEADERPATH="${nixpkgsFor.${system}.janet}/include/janet"
            export JANET_BUILDPATH="$JANET_PATH/build"

            jpm install ${jaylib-src}

            mkdir -p "$JANET_TREE"
            mkdir -p "$JANET_BUILDPATH"

            # Execute the Janet Project Manager build
            jpm build
          '';

          installPhase = ''
            mkdir -p $out/bin
            # Copies the compiled binary to the output bin directory
            cp build/boids $out/bin/
          '';
        };
      });

      hydraJobs = forAllSystems (system: {
        build = self.packages.${system}.default;

        test-suite = nixpkgs.legacyPackages.${system}.runCommand "judge" { } ''
          ${self.packages.${system}.default}/bin/boids --help > $out
          echo "Binary executed successfully" >> $out
        '';
      });

      devShell = forAllSystems (
        system:
        with nixpkgsFor.${system};
        let
          libPath = lib.makeLibraryPath [
            libGL
            libxkbcommon
            wayland
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr
          ];
        in
        mkShell {
          LD_LIBRARY_PATH = libPath;
          packages = [
            janet
            jpm
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
            export JANET_PATH="$PWD/.jpm"
            export JANET_TREE="$JANET_PATH/jpm_tree"
            export JANET_LIBPATH="${janet}/lib"
            export JANET_HEADERPATH="${janet}/include/janet"
            export JANET_BUILDPATH="$JANET_PATH/build"
            export PATH="$PATH:$JANET_TREE/bin"
            export PATH="$PATH:${libPath}"
            mkdir -p "$JANET_TREE"
            mkdir -p "$JANET_BUILDPATH"
            jpm install ${jaylib-src}
          '';
        }
      );
    };
}
