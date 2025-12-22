"""データセットのフォーマットを整える"""

from datasets import load_dataset

if "get_ipython" not in globals():  # Colab環境でない場合は
    from config import *
