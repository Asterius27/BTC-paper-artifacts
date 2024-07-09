import subprocess
from multiprocessing import Pool, current_process
from tqdm import tqdm
import os

def analyze(path: str) -> None:
    print(path)

    result = subprocess.Popen(
        ["git", "symbolic-ref", "refs/remotes/origin/HEAD"],
        stdout=subprocess.PIPE,
        cwd=path
    )
    out, err = result.communicate()
    main_branch = out.decode().strip()

    print(f"Main branch: {main_branch}")

    result = subprocess.Popen(
        ['git', 'rev-list', main_branch],
        stdout=subprocess.PIPE,
        cwd=path
    )

    out, err = result.communicate()

    commits = out.split()
    commits = commits[::-1]

    pid = str(current_process()).split("-")[1].split(" ")[0][:-1]
    pid = int(pid)

    last_commit = ""
    number_of_commits = len(commits)
    for idx, commit in enumerate(tqdm(commits, position=pid, desc=f"Process {pid}")):
        result = subprocess.Popen(
            ['git', 'log', '--format=%B', '-n', '1', commit],
            stdout=subprocess.PIPE,
            cwd=path
        )
        out, err = result.communicate()
        
        if "session protection" in str(out):
            with open(f"results/{path}.txt", "a") as f:
                f.write(f"{number_of_commits - idx - 1} {path} {last_commit}\n{out}\n")
                f.write(f"=========\n")

        result = subprocess.Popen(
            ['git', 'grep', '-i', 'session_protection', commit],
            stdout=subprocess.PIPE,
            cwd=path
        )
        out, err = result.communicate()

        if len(out) > len("session_protection"):
            print(out)
            with open(f"results/{path}.txt", "a") as f:
                f.write(f"{number_of_commits - idx - 1} {path} {last_commit}\n{out}\n")
                f.write(f"=========\n")
        last_commit = commit

def main() -> None:
    # Analyze the repos that are cloned to the current working directory
    repos = [r for r in os.listdir() if os.path.isdir(r)]
    with Pool(32) as p:
        res = p.map(analyze, repos)


main()
