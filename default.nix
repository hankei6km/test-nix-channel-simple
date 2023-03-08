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

  mirageLinemode = pkgs.python3Packages.buildPythonPackage
    rec {
      pname = "mirage_linemode";
      version = "0.1.1";
      format = "setuptools";

      src = pkgs.python3Packages.fetchPypi {
        inherit pname version;
        sha256 = "sha256-Hevq5AOvldmViOmy7h+fBRPKyafH0rjA15qJoOBbPqY=";
      };

      propagatedBuildInputs = [
        pkgs.ranger
        pkgs.python3Packages.pyyaml
        pkgs.python3Packages.configparser
        pkgs.python3Packages.pyxdg
        pkgs.python3Packages.pytest-runner
        pkgs.python3Packages.setuptools
      ];

      doCheck = false;
      # buildInputs = [
      #   pkgs.python3Packages.pytest
      #   pkgs.python3Packages.pytest-cov
      #   pkgs.python3Packages.mock
      # ];


      pythonImportsCheck = [
        "mirage_linemode.config"
        "mirage_linemode.theme.core"
        "mirage_linemode.util"
      ];

      meta = with pkgs.lib; {
        description = "Customizable linemode plugin for ranger";
        homepage = "https://github.com/hankei6km/mirage_linemode";
        license = pkgs.lib.licenses.mit;
        maintainers = with maintainers; [ ];
      };
    };
  rangerWithPlugins = import sources.nixpkgs.ranger {
    propagatedBuildInputs = [ mirageLinemode ];
    overlays = [
      (self: super: {
        inherit propagatedBuildInputs;
      })
    ];
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
        inherit rangerWithPlugins;
      })
      # これをビルドしようとすると `nix-build '<personal>' -A hello2` のようになる。なぜ?
      # (self: super: { 
      #   inherit hello2;
      # })
    ];
  };

in
pkgs
