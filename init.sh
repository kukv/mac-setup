#!/bin/zsh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  zsh init.sh [options]
  curl -sf https://raw.githubusercontent.com/kukv/mac-setup/main/init.sh | zsh -s -- [options]

Options:
  -b, --branch <branch>  Specify the branch to use (default: main)
  -h, --help             Show this help message

Prerequisites:
  Xcode Command Line Tools must be installed manually before running this script.
    xcode-select --install

Extra Variables:
  If ~/.local/etc/extra_vars.yaml exists, it will be passed to ansible-pull as extra vars.
EOF
}

REPO_URL="https://github.com/kukv/mac-setup.git"
BRANCH="main"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b | --branch)
      BRANCH="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

echo "==> Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  echo "Error: Xcode Command Line Tools がインストールされていません。"
  echo "以下のコマンドを実行してインストールしてください:"
  echo ""
  echo "  xcode-select --install"
  echo ""
  echo "インストール完了後、再度このスクリプトを実行してください。"
  exit 1
fi

echo "==> Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Checking Ansible..."
if ! command -v ansible &>/dev/null; then
  echo "Installing Ansible..."
  brew install ansible
fi

echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r \
  "https://raw.githubusercontent.com/kukv/mac-setup/${BRANCH}/ansible/requirements.yaml"

EXTRA_VARS_FILE="${HOME}/.local/etc/extra_vars.yaml"
EXTRA_VARS_OPTS=()
if [[ -f "${EXTRA_VARS_FILE}" ]]; then
  echo "==> Found extra vars: ${EXTRA_VARS_FILE}"
  EXTRA_VARS_OPTS=(--extra-vars "@${EXTRA_VARS_FILE}")
fi

echo "==> Running ansible-pull (branch: ${BRANCH})..."
ansible-pull \
  --url "${REPO_URL}" \
  --checkout "${BRANCH}" \
  --inventory ansible/inventories/hosts.yaml \
  "${EXTRA_VARS_OPTS[@]}" \
  ansible/playbook.yaml
