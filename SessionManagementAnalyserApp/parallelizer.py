from argparse import ArgumentParser
from multiprocessing import cpu_count, Pool
import os
import shutil
import time
from pathlib import Path

parser = ArgumentParser()
parser.add_argument("-s", dest="root_dir", help="Root directory of the repositories", default="./")
parser.add_argument("-l", dest="language", help="Language the repositories are written in", default="", required=True) # TODO for now language detection is not supported
parser.add_argument("-t", dest="threads", help="Number of threads to be used", default=1, type=int)
parser.add_argument("-sl", dest="starsu", help="Upper bound on the number of stars for each repository", default=1000000000000, type=int)
parser.add_argument("-su", dest="starsl", help="Lower bound on the number of stars for each repository", default=0, type=int)
args = parser.parse_args()

def runner(threads, current_thread):
    # os.system('npm run worker -- -s=' + args.root_dir + "/thread" + str(current_thread) + " -l=" + args.language + " -t=" + threads + " -sl=" + args.starsl + " -su=" + args.starsu)
    print('npm run worker -- -s=' + args.root_dir + "/thread" + str(current_thread) + " -l=" + args.language + " -t=" + threads + " -sl=" + args.starsl + " -su=" + args.starsu)

# TODO paths may be wrong, have to test the whole script
if __name__ == '__main__':
    # codeql_threads = cpu_count() // args.threads
    start = time.time()
    codeql_threads = 1
    j = 0
    current_thread = 0
    full_path = Path(__file__).parent / args.root_dir
    print(full_path.absolute())
    """
    repos_dir = os.listdir(full_path.absolute())
    repo_per_thread = len(repos_dir) // args.threads
    for repo_dir in repos_dir:
        if j < repo_per_thread:
            if not os.path.exists(full_path.absolute() + "/thread" + str(current_thread)):
                os.mkdir(full_path.absolute() + "/thread" + str(current_thread))
            shutil.move(full_path.absolute() + "/" + repo_dir, full_path.absolute() + "/thread" + str(current_thread) + "/" + repo_dir)
            j += 1
        else:
            if not os.path.exists(full_path.absolute() + "/thread" + str(current_thread)):
                os.mkdir(full_path.absolute() + "/thread" + str(current_thread))
            shutil.move(full_path.absolute() + "/" + repo_dir, full_path.absolute() + "/thread" + str(current_thread) + "/" + repo_dir)
            current_thread += 1
            if current_thread < args.threads:
                j = 0
            else:
                current_thread -= 1
    with Pool(processes=args.threads) as pool:
        for i in range(args.threads):
            pool.apply_async(runner, (codeql_threads, i))
        pool.close()
        pool.join()
    """
    """
    for i in range(args.threads):
        repos = os.listdir(full_path + "/thread" + str(i))
        for repo in repos:
            shutil.move(full_path + "/thread" + str(i) + "/" + repo, full_path + "/" + repo)
    """
    # os.system('npm run stats -- -s=' + args.root_dir + " -l=" + args.language + " -sl=" + args.starsl + " -su=" + args.starsu)
    print('npm run stats -- -s=' + args.root_dir + " -l=" + args.language + " -sl=" + args.starsl + " -su=" + args.starsu)
    end = time.time()
    print('Elapsed time: ' + str(round((end - start) / 60, 2)) + " minutes")
