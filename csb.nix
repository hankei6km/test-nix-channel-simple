with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "csb";
  buildInputs = [
    niv
    # VSCode の Nix IDE 拡張機能で利用したいが、
    # この方法だと拡張機能側ではインストールされたことにならない、ように見える。
    nixpkgs-fmt
  ];
  shellHook = ''
    '';
}
