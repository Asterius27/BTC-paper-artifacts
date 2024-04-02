from pathlib import Path
import os

repos_path = Path(__file__).parent / './repositories/Flask'
counter = 0

repos_dir = os.listdir(repos_path.absolute())
for dir_name in repos_dir:
    subdirs = os.listdir(str(repos_path.absolute()) + "/" + dir_name)
    for subdir in subdirs:
        if subdir.endswith("-results"):
            queryFile = str(repos_path.absolute()) + "/" + dir_name + "/" + subdir + "/flask_library_used_check.txt"
            with open(queryFile, "r") as output:
                if len(output.readlines()) > 2:
                    with open(str(repos_path.absolute()) + "/" + dir_name + "/" + subdir + "/info.txt", 'a') as res:
                        res.write(", flask")
                        print(str(repos_path.absolute()) + "/" + dir_name + "/" + subdir)
                        counter += 1
print(counter)
