#!/bin/bash
# Unsloth PEFT 初期セットアップスクリプト

set -e

echo "🦥 Unsloth PEFT セットアップを開始します..."
echo ""

# 現在のディレクトリを確認
PROJECT_DIR=$(pwd)
echo "プロジェクトディレクトリ: ${PROJECT_DIR}"
echo ""

# Pythonバージョン確認
echo "📦 Python バージョンを確認..."
python3 --version || { echo "❌ Python3がインストールされていません"; exit 1; }
echo ""

# uvの確認
echo "📦 uv がインストールされているか確認..."
if ! command -v uv &> /dev/null; then
    echo "⚠️  uv がインストールされていません"
    echo "インストール方法:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  source \$HOME/.cargo/env"
    exit 1
fi
echo "✓ uv: $(uv --version)"
echo ""

# 仮想環境の作成
echo "🔧 Python仮想環境を作成..."
if [ -d ".venv" ]; then
    echo "⚠️  .venv が既に存在します。削除して再作成しますか？ (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf .venv
        uv venv
    else
        echo "既存の .venv を使用します"
    fi
else
    uv venv
fi
echo ""

# 依存パッケージのインストール
echo "📥 依存パッケージをインストール..."
source .venv/bin/activate
uv add unsloth
echo ""

# システムパッケージの確認
echo "🔍 システムパッケージを確認..."
MISSING_PACKAGES=()

if ! command -v gcc &> /dev/null; then
    MISSING_PACKAGES+=("build-essential")
fi

if ! dpkg -l | grep -q "python3.12-dev"; then
    MISSING_PACKAGES+=("python3.12-dev")
fi

if ! command -v aria2c &> /dev/null; then
    MISSING_PACKAGES+=("aria2")
fi

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo "⚠️  以下のシステムパッケージが不足しています:"
    printf '  - %s\n' "${MISSING_PACKAGES[@]}"
    echo ""
    echo "インストールしますか？ (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        sudo apt update
        sudo apt install -y "${MISSING_PACKAGES[@]}"
    else
        echo "⚠️  後でインストールしてください: sudo apt install -y ${MISSING_PACKAGES[*]}"
    fi
else
    echo "✓ すべてのシステムパッケージがインストール済みです"
fi
echo ""

# WSL設定の確認
echo "🔍 WSL2 メモリ設定を確認..."
if [ -f "/mnt/c/Users/$(whoami)/.wslconfig" ] || [ -f "/mnt/c/Users/${USER}/.wslconfig" ]; then
    echo "✓ .wslconfig が設定されています"
else
    echo "⚠️  .wslconfig が見つかりません"
    echo "推奨: C:\\Users\\<username>\\.wslconfig を作成してください"
    echo "詳細は README.md を参照"
fi
echo ""

# GPU確認
echo "🎮 GPU を確認..."
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
    echo "✓ GPU が検出されました"
else
    echo "⚠️  nvidia-smi が見つかりません"
    echo "NVIDIA GPUドライバーがインストールされているか確認してください"
fi
echo ""

# メモリ確認
echo "💾 システムメモリを確認..."
free -h | grep "^Mem:"
echo ""

# download_model.sh の実行権限付与
if [ -f "download_model.sh" ]; then
    chmod +x download_model.sh
    echo "✓ download_model.sh に実行権限を付与しました"
fi

# セットアップ完了
echo ""
echo "✅ セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "  1. download_model.sh を編集してモデル名を指定"
echo "  2. ./download_model.sh を実行してモデルをダウンロード"
echo "  3. config.py を編集してトレーニング設定を調整"
echo "  4. source .venv/bin/activate を実行して仮想環境をアクティベート"
echo "  5. uv run fine_tuning.py を実行してトレーニング開始"
echo ""
