from pathlib import Path
import os
import shutil

repos_path = Path(__file__).parent / './repositories/Django'

repos_dir = os.listdir(repos_path.absolute())
for dir_name in repos_dir:
    subdirs = os.listdir(str(repos_path.absolute()) + "/" + dir_name)
    for subdir in subdirs:
        if subdir.endswith("-results") or subdir.endswith("-database"):
            print(str(repos_path.absolute()) + "/" + dir_name + "/" + subdir)
            shutil.rmtree(str(repos_path.absolute()) + "/" + dir_name + "/" + subdir)
