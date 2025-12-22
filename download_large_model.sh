#!/bin/bash
# WSL2で大きなモデルを安全にダウンロードするスクリプト
# 使い方: このファイルのMODEL_NAMEを編集してから実行

set -e

# ===== ここを編集 =====
MODEL_NAME="your-model-name" ## ここはunslothのモデルは指定しない
# 例:
# MODEL_NAME="Llama-3.2-3B-bnb-4bit"
# =====================

CACHE_DIR="$HOME/.cache/huggingface/hub/models--unsloth--${MODEL_NAME}"
BASE_URL="https://huggingface.co/unsloth/${MODEL_NAME}/resolve/main"

echo "🦥 ${MODEL_NAME} のダウンロードを開始します"
echo "保存先: ${CACHE_DIR}"
echo ""

# aria2c がインストールされているか確認
if ! command -v aria2c &> /dev/null; then
    echo "❌ aria2c がインストールされていません"
    echo "インストール: sudo apt install -y aria2"
    exit 1
fi

# ディレクトリ作成
mkdir -p "${CACHE_DIR}/.no_exist"
mkdir -p "${CACHE_DIR}/refs"

# コミットハッシュを取得（APIから）
echo "📡 モデル情報を取得中..."
COMMIT_HASH=$(curl -s "https://huggingface.co/api/models/unsloth/${MODEL_NAME}" | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$COMMIT_HASH" ]; then
    echo "❌ コミットハッシュを取得できませんでした"
    echo "モデル名が正しいか確認してください: unsloth/${MODEL_NAME}"
    exit 1
fi

echo "✓ コミットハッシュ: ${COMMIT_HASH}"
SNAPSHOT_DIR="${CACHE_DIR}/snapshots/${COMMIT_HASH}"
mkdir -p "${SNAPSHOT_DIR}"
cd "${SNAPSHOT_DIR}"

# refs/main にハッシュを保存
echo "${COMMIT_HASH}" > "${CACHE_DIR}/refs/main"

# メタデータディレクトリ作成
mkdir -p "${CACHE_DIR}/.no_exist/${COMMIT_HASH}"

# 必要なファイルのリスト
FILES=(
    "config.json"
    "generation_config.json"
    "model.safetensors"
    "special_tokens_map.json"
    "tokenizer.json"
    "tokenizer.model"
    "tokenizer_config.json"
)

echo ""
echo "📥 小さなファイルを先にダウンロード..."
for file in "${FILES[@]}"; do
    if [ "$file" != "model.safetensors" ]; then
        echo "  - $file"
        # ファイルが存在しない場合はスキップ（エラーでも継続）
        if ! aria2c -x 4 -s 4 -k 1M -c --auto-file-renaming=false \
            --allow-overwrite=true \
            "${BASE_URL}/${file}" -o "$file" 2>&1; then
            echo "    ⚠️  スキップ ($file はダウンロードできませんでした)"
        fi
    fi
done

echo ""
echo "📥 model.safetensors (大容量) をダウンロード中..."
echo "   接続数を制限して安定性を優先します"
echo "   中断した場合は再度実行してください（途中から再開します）"
echo ""

# 大きなファイルは慎重にダウンロード
aria2c \
    -x 4 \
    -s 4 \
    -k 1M \
    -c \
    --max-download-limit=20M \
    --auto-file-renaming=false \
    --allow-overwrite=true \
    --summary-interval=30 \
    "${BASE_URL}/model.safetensors" \
    -o "model.safetensors"

echo ""
echo "✅ ダウンロード完了！"
echo ""
echo "モデルの場所: ${SNAPSHOT_DIR}"
ls -lh "${SNAPSHOT_DIR}"
echo ""
echo "🎉 これで fine_tuning.py を実行できます！"

