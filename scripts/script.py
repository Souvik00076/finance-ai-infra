import os
import subprocess
from urllib.parse import urlparse
import argparse
import sys
import shutil

#method to extract the repo name from given url
def extract_repo_name(github_url):
    if github_url.endswith(".git"):
        github_url=github_url[:-4]
    #for ssh name
    if github_url.startswith('git@github.com:'):
        repo_path=github_url.split(":")[1]
    #for https
    else:
        parsed=urlparse(github_url)
        repo_path=parsed.path.strip('/')
    return repo_path.split('/')[-1]

#method to check whether repo exists in the cwd or not
def repo_exists(repo_name):
    return os.path.isdir(repo_name)

#clone repository if not exist
def clone_repository(github_url,target_dir=None,target_branch=None):
    try:
        cmd=["git","clone"]
        if target_branch:
            cmd.extend(["-b",target_branch])
        cmd.append(github_url)
        if target_dir:
            cmd.append(target_dir)
        branch_info = f" (branch: {target_branch})" if target_branch else ""
        print(f"Cloning the repository from {github_url}{branch_info}")
        subprocess.run(cmd,check=True,capture_output=True,text=True)
        print(f"Successfully clone repository!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error cloning repository {e}")
        print(f"Git output : {e.stderr}")
        return False
    except FileNotFoundError:
        print("Error : Git is not installed or incorrect repo")
        return False

#spin up docker compose
def spin_up_docker_compose(rebuild=False,build_path="finance-ai-backend"):
    try:
        env=os.environ.copy()
        build_context=os.path.join(".",build_path)
        env['BUILD_CONTEXT'] = build_context
        print(f"Using build context: {build_context}")
        print(f"Closing Existing Docker Services")
        try:
            cmd=["docker-compose","down"]
            subprocess.run(
            cmd,
            env=env,
            check=True
        )
        except BaseException as e:
            print("All containers down")
        print(f"Spinning Up New Containers")
        cmd=["docker-compose","up","--scale","backend=5"]
        if rebuild:
            cmd.append("--build")
        subprocess.run(
            cmd,
            env=env,
            check=True
        )
        return True
    except BaseException as e:
        print(f"Error : {e}")
        return False
def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(script_dir)
    os.chdir(parent_dir)
    print(f"Changed working directory to: {os.getcwd()}")
    parser = argparse.ArgumentParser(
        description="Clone a GitHub repository if not present in current directory"
    )
    parser.add_argument(
        "github_url", 
        help="GitHub repository URL (HTTPS or SSH)"
    )
    parser.add_argument(
        "-d", "--directory",
        help="Custom directory name for the cloned repository"
    )
    parser.add_argument(
        "-b", "--branch",
        help="Optional branch name to clone"
    )
    parser.add_argument(
        "-f", "--force",
        action="store_true",
        help="Force clone even if directory exists"
    )
    args=parser.parse_args()
    if not (args.github_url.startswith('https://github.com/') or 
            args.github_url.startswith('git@github.com:')):
        print("Error: Please provide a valid GitHub URL")
        sys.exit(1)
    target_dir = args.directory if args.directory else extract_repo_name(args.github_url)
    target_branch=args.branch if args.branch else None
    # Check if repository already exists
    if repo_exists(target_dir):
        if args.force:
            print(f"Directory '{target_dir}' exists but --force flag is set. Proceeding with clone...")
            shutil.rmtree(target_dir)
        else:
            print(f"Repository '{target_dir}' already exists in current directory.")

   
    success = clone_repository(args.github_url, target_dir if args.directory else None,target_branch)
    if success:
        print(f"Repository cloned to: {os.path.abspath(target_dir)}")
    if args.directory:
        success = spin_up_docker_compose(True if args.force else False, args.directory)
    else:
        success = spin_up_docker_compose(True if args.force else False)
    if success==False:
        sys.exit(1)

#Main
if __name__ == "__main__":
    main()