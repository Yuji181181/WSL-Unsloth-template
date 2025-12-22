"""Fine-Tuningの設定"""

# モデルとデータセットの指定
MODEL_NAME = "unsloth/your-model-name"
DATASET_NAME = "your-dataset-name"

# データセットのサイズやモデルを制限するための変数
MAX_DATASET_SIZE = 500
MAX_SEQ_LENGTH = 2048
MAX_STEPS = 1  # 学習のステップ数 (テストのときは1)

# モデルの保存先ディレクトリ
MODEL_SAVE_DIR = ""
