let

  sources = import ./nix/sources.nix;

  podmanComposeGit = pkgs.python3Packages.buildPythonApplication
    rec {
      # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/applications/virtualization/podman-compose/default.nix#L17
      version = "1.0.4-08ffcf6-git";
      pname = "podman-compose-git";

      src = builtins.fetchurl {
        url = "https://github.com/containers/podman-compose/archive/08ffcf6126a3ae4016e3d81e963a3629e4b75986.tar.gz";
        sha256 = "9b6c607622d643279d74c6f054d93014aad224c2fc9e4899d71478b949e4e139";
      };

      propagatedBuildInputs = [ pkgs.python3Packages.pyyaml pkgs.python3Packages.python-dotenv ];

      meta = {
        description = "An implementation of docker-compose with podman backend - GIT version";
        homepage = "https://github.com/containers/podman-compose";
        license = pkgs.lib.licenses.gpl2Only;
        platforms = pkgs.lib.platforms.unix;
        maintainers = [ pkgs.lib.maintainers.sikmir ] ++ pkgs.lib.teams.podman.members;
      };
    };

  fakePodmanDocker = pkgs.writeShellScriptBin "docker" ''
    podman "''${@}"
  '';

  fakePodmanScript = pkgs.writeShellScriptBin "podman" ''
    if test "''${1}" = "compose" && command -v podman-compose > /dev/null ; then
      shift
      podman-compose "''${@}"
      exit "''${?}"
    fi
    command -p podman "''${@}"
  '';

  podmanComposeFakeeVersionScript = pkgs.writeShellScriptBin "podman-compose-fake-version" ''
    if test "''${1}" = "version"; then
        /usr/local/bin/docker-compose "''${@}"
    else
        podman-compose "''${@}"
    fi
  '';

  podmanComposeFakeeVersion = pkgs.stdenv.mkDerivation {
    name = "podman-compose-fake-version";
    buildInputs = [
      podmanComposeGit
      podmanComposeFakeeVersionScript
    ];
    buildCommand = ''
      install -m555 -Dt $out/bin "$(command -v podman-compose)"
      install -m555 -Dt $out/bin "$(command -v podman-compose-fake-version)"
    '';
  };

  # hello2 = pkgs.writeShellScriptBin "hello1" ''
  #   echo "Hello from the Nix channel overlay!"
  # '';

  pkgs = import sources.nixpkgs {
    overlays = [
      (self: super: {
        inherit podmanComposeGit;
      })
      # これをビルドしようとすると Docker もインストールする。なぜ?
      (self: super: {
        inherit fakePodmanDocker;
      })
      (self: super: {
        inherit fakePodmanScript;
      })
      (self: super: {
        inherit podmanComposeFakeeVersion;
      })
      # これをビルドしようとすると `nix-build '<personal>' -A hello2` のようになる。なぜ?
      # (self: super: { 
      #   inherit hello2;
      # })
    ];
  };

in
pkgs
