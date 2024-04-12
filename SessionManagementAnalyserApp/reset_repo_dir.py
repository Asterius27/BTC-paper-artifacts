import os
import shutil
from pathlib import Path

full_path = Path(__file__).parent / "./repositories/Flask"
threads = 20
for i in range(threads):
    repos = os.listdir(str(full_path.absolute()) + "/thread" + str(i))
    for repo in repos:
        dirs = os.listdir(str(full_path.absolute()) + "/thread" + str(i) + "/" + repo)
        for dir in dirs:
            if dir.endswith("-database") and os.path.exists(str(full_path.absolute()) + "/thread" + str(i) + "/" + repo + "/" + dir):
                shutil.rmtree(str(full_path.absolute()) + "/thread" + str(i) + "/" + repo + "/" + dir, ignore_errors=True)
        shutil.move(str(full_path.absolute()) + "/thread" + str(i) + "/" + repo, str(full_path.absolute()) + "/" + repo)
    os.rmdir(str(full_path.absolute()) + "/thread" + str(i))
