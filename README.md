# WSL-Unsloth-template

WSL環境でUnslothを使ったファインチューニング用のテンプレート


## 前提条件

### システム要件
- Windows 11/10 + WSL2 (Ubuntu 24.04推奨)
- NVIDIA GPU (CUDA対応)
- メモリ: 32GB以上推奨
- ストレージ: 10GB以上の空き容量

## 初回のみ実行（PC全体の設定）

このPCで初めてUnslothを使う場合のみ実行してください

### 1. WSL2のメモリ設定

Windowsで `C:\Users\<ユーザー名>\.wslconfig` を作成：

```ini
[wsl2]
memory=30GB
processors=20
swap=16GB
networkingMode=mirrored  # Windows 11のみ
dnsTunneling=true        # Windows 11のみ
autoProxy=true           # Windows 11のみ
nestedVirtualization=true
pageReporting=true
localhostForwarding=true
```

**Windows 10の場合**: `networkingMode`、`dnsTunneling`、`autoProxy` の行を削除

設定後、PowerShell（管理者権限）で実行：
```powershell
wsl --shutdown
```

### 2. 必要なパッケージのインストール

WSL2内で実行：

```bash
# ビルドツール
sudo apt update
sudo apt install -y build-essential python3.12-dev aria2

# Python環境管理ツール（uv）
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env
```

## プロジェクトごとのセットアップ

### 1. テンプレートから作成

```bash
cd ~/GitHub
git clone <SSH_URL>
cd <WSL-Unsloth-template>
```

### 2. 初期セットアップ

```bash
./setup.sh
```

これにより以下が自動で実行されます：
- Python仮想環境の作成
- 必要なパッケージのインストール
- 設定の確認

### 3. モデル名を編集

- download_large_model.shの MODEL_NAME を編集

### 4. モデルダウンロード

```bash
./download_large_model.sh
```

### 5. 設定をカスタマイズ

```
├── config.py                   # トレーニング設定
├── dataset_formatter.py        # データセット整形
├── fine_tuning.py              # PEFT
├── generate.py                 # 推論用スクリプト
```

### 6. トレーニング実行

```bash
source .venv/bin/activate
```

```bash
uv run fine_tuning.py
```

## ファイル構成

```
├── setup.sh                    # 初期セットアップスクリプト
├── download_large_model.sh     # モデルダウンロードスクリプト
├── config.py                   # トレーニング設定
├── dataset_formatter.py        # データセット整形
├── fine_tuning.py              # PEFT
├── generate.py                 # 推論用スクリプト
├── pyproject.toml              # 依存関係定義
```
