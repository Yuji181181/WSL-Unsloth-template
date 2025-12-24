"""Fine-Tuningを行う"""

import os

# PyTorchの動的コンパイルを完全に無効化（nvccエラーを回避）
os.environ["PYTORCH_COMPILE_DISABLE"] = "1"
os.environ["TORCHDYNAMO_DISABLE"] = "1"
