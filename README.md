# mac-setup

Ansible Playbook による macOS セットアップ自動化ツール。

Homebrew パッケージ、CLI ツール (mise)、シェル設定 (zsh + Oh My Zsh)、Git/SSH 設定、iTerm2 プロファイルなどを一括でセットアップし、LaunchAgent による週次自動更新で環境を維持する。

## Quick Start

### 1. 事前準備

```bash
xcode-select --install
```

### 2. extra_vars.yaml の作成

`extra_vars.yaml.example` を参考に `~/.local/etc/extra_vars.yaml` を作成する。

```bash
mkdir -p ~/.local/etc
cp extra_vars.yaml.example ~/.local/etc/extra_vars.yaml
# エディタで値を編集
```

### 3. セットアップ実行

```bash
curl -sf https://raw.githubusercontent.com/kukv/mac-setup/main/init.sh | zsh
```

ブランチを指定する場合:

```bash
curl -sf https://raw.githubusercontent.com/kukv/mac-setup/main/init.sh | zsh -s -- -b <branch>
```

## 初回セットアップ後の手動作業

[MANUAL_INSTALL.md](MANUAL_INSTALL.md) を参照。
