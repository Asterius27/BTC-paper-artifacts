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
    os.system('npm run worker -- -s=' + args.root_dir + "/thread" + str(current_thread) + " -l=" + args.language + " -t=" + str(threads) + " -sl=" + str(args.starsl) + " -su=" + str(args.starsu) + " -ct=" + str(current_thread))
    # print('npm run worker -- -s=' + args.root_dir + "/thread" + str(current_thread) + " -l=" + args.language + " -t=" + str(threads) + " -sl=" + str(args.starsl) + " -su=" + str(args.starsu) + " -ct=" + str(current_thread))

# TODO have to test the whole script
if __name__ == '__main__':
    start = time.time()
    # codeql_threads = 1
    codeql_threads = (cpu_count() // args.threads) - 1
    j = 0
    current_thread = 0
    full_path = Path(__file__).parent / args.root_dir
    # print(str(full_path.absolute()))
    repos_dir = os.listdir(full_path.absolute())
    repo_per_thread = len(repos_dir) // args.threads
    # TODO improve this: it's not 100% balanced (the first n-1 threads will have repo_per_thread + 1 repos while the last will have repo_per_thread minus the extra ones that the other threads took instead)
    for repo_dir in repos_dir:
        if j < repo_per_thread:
            if not os.path.exists(str(full_path.absolute()) + "/thread" + str(current_thread)):
                os.mkdir(str(full_path.absolute()) + "/thread" + str(current_thread))
            shutil.move(str(full_path.absolute()) + "/" + repo_dir, str(full_path.absolute()) + "/thread" + str(current_thread) + "/" + repo_dir)
            j += 1
        else:
            if not os.path.exists(str(full_path.absolute()) + "/thread" + str(current_thread)):
                os.mkdir(str(full_path.absolute()) + "/thread" + str(current_thread))
            shutil.move(str(full_path.absolute()) + "/" + repo_dir, str(full_path.absolute()) + "/thread" + str(current_thread) + "/" + repo_dir)
            # print(current_thread)
            current_thread += 1
            if current_thread < args.threads:
                # print("Resetting j... " + str(current_thread))
                j = 0
            else:
                # print(current_thread)
                current_thread -= 1
    print("Now starting the thread workers...")
    with Pool(processes=args.threads) as pool:
        for i in range(args.threads):
            pool.apply_async(runner, (codeql_threads, i))
        pool.close()
        pool.join()
    print("Thread workers are done!")
    for i in range(args.threads):
        repos = os.listdir(str(full_path.absolute()) + "/thread" + str(i))
        for repo in repos:
            shutil.move(str(full_path.absolute()) + "/thread" + str(i) + "/" + repo, str(full_path.absolute()) + "/" + repo)
        os.rmdir(str(full_path.absolute()) + "/thread" + str(i))
    os.system('npm run stats -- -s=' + args.root_dir + " -l=" + args.language + " -sl=" + str(args.starsl) + " -su=" + str(args.starsu))
    # print('npm run stats -- -s=' + args.root_dir + " -l=" + args.language + " -sl=" + str(args.starsl) + " -su=" + str(args.starsu))
    end = time.time()
    print('Elapsed time: ' + str(end - start) + " seconds")
    with open("log_parallelizer.txt", "a") as f:
        f.write('Elapsed time: ' + str(end - start) + " seconds\n")
        f.write('Params used: dir: ' + args.root_dir + ", lang: " + args.language + ", threads: " + str(args.threads) + ", stars lower bound: " + str(args.starsl) + ", stars upper bound: " + str(args.starsu) + "\n")
