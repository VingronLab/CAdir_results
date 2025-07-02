import argparse

parser = argparse.ArgumentParser(description="Parser for scG")
parser.add_argument("--file_path", default="./", type=str)
parser.add_argument("--save_path", default="./", type=str)
args = parser.parse_args()
