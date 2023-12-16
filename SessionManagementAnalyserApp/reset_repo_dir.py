import os
import shutil
from pathlib import Path

full_path = Path(__file__).parent / "./repositories/Flask"
threads = 15
for i in range(threads):
    repos = os.listdir(str(full_path.absolute()) + "/thread" + str(i))
    for repo in repos:
        shutil.move(str(full_path.absolute()) + "/thread" + str(i) + "/" + repo, str(full_path.absolute()) + "/" + repo)
    os.rmdir(str(full_path.absolute()) + "/thread" + str(i))