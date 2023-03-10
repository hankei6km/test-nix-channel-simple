# test-nix-channel-simple

主に CodeSandbox で個人用のパッケージを利用するために作成。 下記を参考尾にしている。

https://lucperkins.dev/blog/nix-channel/

が、まだ Nix のことを理解できていないので、なんとなく動くという程度。

## 利用方法

```
nix-channel --add "https://github.com/hankei6km/test-nix-channel-simple/archive/v0.4.0.tar.gz" personal
nix-channel --update
```

### `podman-compose-git`

```
nix-env -iA personal.podmanComposeGit
```

- `config` コマンドが使えるバージョン
  - ただし PATH の扱いが `docker-compose` とは異なる(絶対 PATH へ変換されない)

`dokcer-compose.yml` 内に記述してる各種 PATH を絶対 PATH へ変更すると Dev Containers で利用できなくもない。

### `fake-podman-docker`

```
nix-env -iA personal.fakePodmanDocker
```

- `podman-docker` パッケージのような簡易版スクリプト

Nix では `podman-docker` パッケージが無いようだったので作成。
`devcontainer feature test` サブコマンドでは `--docker-path` が使えないのでこれを利用する。

### `podman-compose-fake-version`

```
nix-env -iA personal.fakePodmanScript
```

- `compose` サブコマンドを疑似的にサポートする `podmann` スクリプト

Dev Container 拡張機能が `podman compose version --short` を実行するようになったので作成。[これを使っても回避できない](https://zenn.dev/link/comments/36ed3c9c12c8a2)ので利用する意味はなくなった。

### `podman-compose-fake-version`

```
nix-env -iA personal.podmanComposeFakeeVersion
```

- `version` サブコマンドだけ `dokcer-compose` を使う `podman-compose`

Dev Container 拡張機能が `podman-compose version --short` に結果に[特定バージョンを要求すると勘違い](https://zenn.dev/link/comments/36ed3c9c12c8a2)して作成。特に利用する意味はなくなったが、自分用サンプルとして残しておく。
