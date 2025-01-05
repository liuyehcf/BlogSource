---
title: git
date: 2017-08-11 14:02:55
top: true
tags: 
- 摘录
categories: 
- Version Control
---

**阅读更多**

<!--more-->

# 1 Basic Concepts

![fig1](/images/git/fig1.png)

## 1.1 Workspace

The collection of all files you are working on, managed by git.

## 1.2 Repository

The workspace contains a hidden directory `.git`, which is not considered part of the workspace but is the Git repository.

The Git repository stores many things, with the most important being the **staging area**, also known as the `stage` or `index`, the first branch created automatically by Git called `master`, and a pointer to `master` called `HEAD`.

**In the following text, `Index` will represent the staging area, `HEAD` will represent the latest commit of the current branch, and `Repository` will represent the commit area.**

# 2 Configuration

**Filepath:**

* `~/.gitconfig`: For global config
* `.git/config`: For project config

```sh
git config --list [--global]

git config -e [--global]

git config [--global] user.name "[name]"
git config [--global] user.email "[email address]"

git config [--global] --unset http.proxy
```

## 2.1 Alias

```sh
# <xxx ago> Time Format
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# <day> Time Format
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cs, %cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# <second> Time Format
git config --global alias.lg "log --color --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd, %cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=format:'%Y-%m-%d %H:%M:%S'"
```

## 2.2 Modify Default Editor

```sh
git config --global core.editor "vim"
git config --global core.editor "nvim"
```

## 2.3 Modify Diff Tool

[Github Topic - diff](https://github.com/topics/diff)

### 2.3.1 delta

[github-delta](https://github.com/dandavison/delta)

**[Install](https://dandavison.github.io/delta/installation.html)**

**Config:**

```sh
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.dark false
git config --global delta.syntax-theme GitHub
git config --global delta.side-by-side true
git config --global merge.conflictStyle zdiff3
```

**Usage:**

```sh
git diff HEAD
git diff -a HEAD
git show HEAD
git show -a HEAD

# comparison for binary files
delta -@=--text a.binary b.binary
```

### 2.3.2 icdiff (Deprecated)

[github-icdiff](https://github.com/jeffkaufman/icdiff)

**Install:**

```sh
pip3 install git+https://github.com/jeffkaufman/icdiff.git

git difftool --extcmd icdiff

git config --global icdiff.options '--highlight --line-numbers'
```

**Usage:**

* `git icdiff`
* `git icdiff HEAD`
* `git icdiff -- <file>`

# 3 Adding/Deleting Files

```sh
# Add specified files to the staging area
git add [file1] [file2] ...

# Add specified directory to the staging area, including subdirectories
git add [dir]

# Add all files in the current directory to the staging area
git add .

# Add tracked files to the staging area, without adding new files
git add -u

# Require confirmation before adding each change
# Allows multiple commits for different changes in the same file
git add -p

# Delete a file from the workspace and add this deletion to the staging area
git rm [file1] [file2] ...

# Stop tracking a specified file, but keep it in the workspace
git rm --cached [file]

# Stop tracking all files, but keep them in the workspace
git rm -r --cached .

# View files tracked by git
git ls-files

# Rename a file and add this renaming to the staging area
git mv [file-original] [file-renamed]
```

## 3.1 Permanently Deleting Files

**How to find large files in the repository history:**

```sh
git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5 | awk '{print$1}')"
```

**Step 1: Use `filter-branch` to rewrite all commits involving these large files (rewriting history is a very dangerous operation):**

```sh
# This command will checkout each commit and execute the bash command specified in the --index-filter parameter
git filter-branch -f --prune-empty --index-filter 'git rm -rf --cached --ignore-unmatch [your-file-name]' --tag-name-filter cat -- --all
```

**Step 2: Push all local branches to the remote repository. Without the `--all` option, only the default or specified branch will be pushed. If other branches in the remote repository still contain the large file, it will remain in the repository.**

```sh
git push origin --force --all
```

**Step 3: Delete related records in the local repository**

```sh
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now
```

# 4 Submit

```sh
# Commit the staging area to the repository
git commit -m [message]

# Commit specified files from the staging area to the repository
git commit [file1] [file2] ... -m [message]

# Commit changes in the workspace since the last commit directly to the repository
git commit -a

# Show all diff information when committing
git commit -v

# Replace the last commit with a new commit
# If there are no new changes, use this to rewrite the last commit message
git commit --amend -m [message]

# Redo the last commit and include changes to specified files
git commit --amend [file1] [file2] ...
```

# 5 Undo

```sh
# Restore all files in the workspace to the staging area
git checkout -- .

# Restore specified files in the workspace to the staging area
git checkout -- [file]

# Restore specified files from a branch to the staging area
git checkout [branch] -- [file]

# Restore specified files from a commit to the staging area
git checkout [commit] -- [file]

# Reset specified files in the staging area to match the last commit, but leave the workspace unchanged
git reset [file]

# Reset the staging area and the workspace to match the last commit
git reset --hard

# Reset the current branch pointer to a specified commit, reset the staging area, but leave the workspace unchanged
git reset [commit]

# Reset the current branch HEAD to a specified commit, and reset both the staging area and the workspace to match the specified commit
git reset --hard [commit]

# Reset the current HEAD to a specified commit, but leave the staging area and the workspace unchanged
git reset --keep [commit]

# Create a new commit to revert a specified commit
# The changes from the specified commit will be negated by the new commit and applied to the current branch
git revert [commit]

# Save uncommitted changes to the stash
git stash -m [message]

# Pop the stash and apply the saved changes to the workspace
git stash pop

# List stashes
git stash list

# Apply a specified stash
git stash apply [id]

# Drop a specified stash
git stash drop [id]

# Show the list of files changed in a specified stash
git stash show [id]

# Show the changes in a specified stash
git stash show [id] -p

# Show the difference between a specified stash and the current state
# For example: git diff stash@{0}
git diff stash@{[id]}

# Clear all stashes
git stash clear

# Discard changes in the workspace
git restore [file]

# Restore specified files from the staging area to the workspace
git restore --staged [file]
```

# 6 Branch

```sh
# List all local branches
git branch

# List all local branches with details
git branch -vv

# List all remote branches
git branch -r

# List all local and remote branches
git branch -a

# Create a new branch but stay on the current branch
git branch [branch-name]

# Create a new branch and switch to it
git checkout -b [branch]

# Fetch a specified branch from the remote repository, create a new local branch, and switch to it
git checkout -b [branch_local] origin/[branch_remote]

# Create a new branch pointing to a specified commit
git branch [branch] [commit]

# Create a new branch and set up a tracking relationship with a specified remote branch
git branch --track [branch] [remote-branch]

# Switch to a specified branch and update the workspace
git checkout [branch-name]

# Switch to the previous branch
git checkout -

# Set up a tracking relationship between the current branch and a specified remote branch
git branch --set-upstream [branch] [remote-branch]

# Merge a specified branch into the current branch
git merge [branch]

# Rebase a specified branch onto the current branch
git rebase [branch]

# During a rebase, if there are conflicts, continue the rebase after resolving them
git rebase --continue

# During a rebase, if there are conflicts or errors, abort the entire rebase
git rebase --abort

# Rebase the current branch with commits in the (startcommit, endcommit] range (left-open, right-closed)
git rebase -i [startcommit] [endcommit]

# Rebase the current branch with commits in the (startcommit, HEAD] range (left-open, right-closed)
git rebase -i [startcommit]

# Rebase the current branch, specifying startcommit as root (root refers to the position before the first commit)
git rebase -i --root

# Select a commit and merge it into the current branch (commits are ordered chronologically from left to right)
git cherry-pick [commit1] [commit2] ...

# Delete a branch
git branch -d [branch-name]

# Delete a remote branch
git push origin --delete [branch-name]
git branch -dr [remote/branch]

# Rename a branch
git branch -m [oldbranch] [newbranch]
git branch -M [oldbranch] [newbranch]
```

# 7 Tag

```sh
# List all tags
git tag

# Create a new tag on the current commit
git tag [tag]

# Create a new tag on a specified commit
git tag [tag] [commit]

# Delete a local tag
git tag -d [tag]

# Delete a remote tag
git push origin :refs/tags/[tagName]

# View tag information
git show [tag]

# Push a specified tag
git push [remote] [tag]

# Push all tags
git push [remote] --tags

# Create a new branch pointing to a tag
git checkout -b [branch] [tag]
```

# 8 Log

```sh
# Show changed files
git status

# Show version history of the current branch
git log

# Show commit history and the files changed in each commit
git log --stat

# Search commit history by keyword
git log -S [keyword]

# Show all changes after a specific commit, with each commit on one line
git log [tag] HEAD --pretty=format:%s

# Show all changes after a specific commit, with commit messages matching the search criteria
git log [tag] HEAD --grep feature

# Show version history of a specific file, including renames
git log --follow [file]

# Show modification records related to a specific file
git log [file]

# Show every diff related to a specific file
git log -p [file]

# Show the last 5 commits in a concise format
git log -5 --pretty --oneline

# Show dates in a specified format
git log --date=format:"%Y-%m-%d %H:%M:%S"

# Show all committers sorted by number of commits
git shortlog -sn

# Show who changed each line of a file and when
git blame [file]

# Show a summary of the differences between the staging area and the workspace (number of lines changed, not specific changes)
git diff --stat

# Show differences between the staging area and the workspace
git diff

# Show differences between the staging area and the last commit
git diff --cached
git diff --cached [file]

# Show differences between the workspace and the latest commit of the current branch
git diff HEAD

# Show differences between two commits
git diff [first-branch]...[second-branch]

# Show how many lines of code you wrote today
git diff --shortstat "@{0 day ago}"

# Show metadata and content changes of a specific commit
git show [commit]

# Show metadata and content changes of a specific commit for a file
git show [commit] -- [filename]

# Show metadata and statistics of content changes for a specific commit
git show [commit] --stat

# Show files changed in a specific commit
git show --name-only [commit]

# Show content of a file at a specific commit
git show [commit]:[filename]

# Show a list of files changed in each commit
git whatchanged

# Show a list of files changed in each commit with statistics
git whatchanged --stat

# Show version history of a specific file, including renames
git whatchanged [file]

# Show recent commits of the current branch
git reflog
```

# 9 Clone

```sh
# Download using HTTPS
git clone https://github.com/xxx/yyy.git

# Download using SSH
git clone git@github.com:xxx/yyy.git

# Download without history commits (shallow clone)
# When the repository is very large, downloading everything can be time-consuming and storage-intensive
# We can specify a depth of 1 to only download the latest version, called a "shallow" clone
git clone https://github.com/xxx/yyy.git --depth 1
git clone -b [branch_name] https://github.com/xxx/yyy.git --depth 1

# If later you want to download the full repository, you can use the following command to get the complete history
git fetch --unshallow

# Using <--depth 1> can cause another issue: you won't be able to fetch other branches. You can handle this as follows
git remote set-branches origin '[branch_name]'
git fetch --depth 1 origin '[branch_name]'
```

# 10 Sync

```sh
# Fetch updates from all branches of the specified remote repository, but does not apply them to any local branches. The updates are stored in the remote-tracking branches.
git fetch [remote]

# Fetch updates from the specified branch on the remote repository, but does not apply them to any local branch. The updates are stored in the remote-tracking branch.
git fetch [remote] [branch]

# Fetch updates from the specified branch on the remote repository and applies them to the specified local branch, creating the local branch if it does not already exist.
git fetch [remote] [branch]:[local_branch]

# Fetch updates from the specified branch on the remote repository and forces the update to be applied to the specified local branch, creating it if necessary.
# It may be refused when you at [local_branch], because git fetch is designed to be a safe operation that doesn't modify the working directory.
# It works fine when you are at another branch, like tmp.
git fetch [remote] -f [branch]:[local_branch]

# Fetch a specific commit from the specified remote repository, but does not apply it to any local branch. The fetched commit is stored in the remote-tracking branch.
git fetch [remote] [commit]

# Fetch the changes from pull request number 29048 from the specified remote repository. The changes are stored in the remote-tracking branch but are not applied to any local branch.
git fetch [remote] pull/29048/head

# Fetch the changes from pull request number 29048 from the specified remote repository and applies them to a new local branch named `pull_request_29048`.
git fetch [remote] pull/29048/head:pull_request_29048

# Removes any remote-tracking references that no longer exist in the remote repository.
git fetch --prune

# Displays the URLs of all remote repositories associated with the local repository, showing both fetch and push URLs.
git remote -v

# Displays detailed information about the specified remote repository, including its branches, tracking information, and recent commits.
git remote show [remote]

# Add a new remote repository with the specified shortname and URL to your local Git repository.
git remote add [shortname] [url]

# Fetch changes from the specified remote branch and merges them into the current local branch.
git pull [remote] [branch]

# Fetch changes from the specified remote branch and merges them into the specified local branch, forcing the update if necessary.
git pull [remote] -f [branch]:[local_branch]

# Upload (pushes) the local branch to the specified remote repository branch.
git push [remote] [branch]

# Forcefully update the specified remote branch with the local branch, potentially overwriting changes on the remote branch.
git push [remote] -f [branch]:[remote_branch]
```

# 11 Submodule

Commit hash of each submodule is stored as normal git object. You can check it by `git submodule status`

```sh
# Add submodule to current git project
git submodule add [repository_url] [path/to/submodule]
git submodule add -b [branch_name] [repository_url] [path/to/submodule]

# Init and checkout to the specific commit
git submodule update --init --recursive

# Update repository
git submodule sync --recursive
git submodule sync --recursive [path/to/submodule]

# Check Status
git submodule status
```

# 12 Plugin

[git-extra](https://github.com/tj/git-extras)

```sh
# Statistics on code contributions
git summary --line
```

# 13 Publish

```sh
# Generate a distributable archive
git archive
```

# 14 .gitignore

**基础规则**

**Basic Rules**

1. Empty lines do not match any files, they are used to enhance readability.
1. Lines starting with `#` are comments.
1. Trailing spaces at the end of lines are ignored unless they are escaped with a `\`.
1. Lines starting with `!` negate the pattern that follows (by default, `.gitignore` rules ignore files; negation includes them).
1. Lines ending with `/` indicate that the pattern matches a directory and everything within it.
1. Patterns not containing a `/` match both files and directories.
1. `*` matches multiple characters, excluding `/`.
1. `?` matches a single character, excluding `/`.
1. `[]` matches any one of the enclosed characters.
1. Patterns starting with `/` indicate an absolute path, beginning at the root directory. For example, `/*.c` matches `cat-file.c` but not `mozilla-sha1/sha1.c`.
1. `**/` at the start of a pattern matches all directories. For example, `**/foo` matches any directory or file named `foo`. **`**/foo` and `foo` are equivalent.**
1. `/**` at the start of a pattern matches everything inside. For example, `abc/**` matches all files within the `abc` directory. **`abc/**` and `abc/` are equivalent.**
1. `/**/` matches zero or more directories. For example, `a/**/b` matches `a/b`, `a/x/b`, and `a/x/y/b`.

# 15 git-lfs

[Git Large File Storage](https://git-lfs.github.com/)

# 16 git-worktree

[git-worktree](https://git-scm.com/docs/git-worktree)

# 17 gist

Gists allow developers to share code or text snippets with others, making it easy to collaborate or seek help with specific programming tasks.

[Gist](https://gist.github.com/)

# 18 copilot

[copilot](https://github.com/features/copilot)

# 19 Tips

## 19.1 Install Latest Version

### 19.1.1 Centos

```sh
sudo yum -y remove git
sudo yum -y remove git-*

sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm

sudo yum install git
```

### 19.1.2 From Source

* [git-tags](https://github.com/git/git/tags)

```sh
export VERSION=2.45.2
wget -O git-${VERSION}.tar.gz "https://github.com/git/git/archive/refs/tags/v${VERSION}.tar.gz"
tar -zxvf git-${VERSION}.tar.gz

cd git-${VERSION}
export DEFAULT_HELP_FORMAT="man"
autoconf
./configure --prefix=/usr/local
make -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo make install
```

## 19.2 Issue with Chinese Displayed in Octal Form

In Windows, git bash may display Chinese characters as `\+three digits` in octal notation. You can resolve this issue with the following command:

```sh
git config --global core.quotepath false
```

## 19.3 Proxy

### 19.3.1 SSH Protocol

Edit `~/.ssh/config`

```conf
Host github.com
   # HostName github.com
   Hostname ssh.github.com
   Port 443
   User git
   # Go through socks5 proxy, like Shadowsocks
   ProxyCommand nc -v -x 127.0.0.1:7890 %h %p
```

### 19.3.2 HTTP Protocol

```sh
git config --global http.proxy "http://127.0.0.1:7890"
git config --global https.proxy "https://127.0.0.1:7890"
```

## 19.4 DNS

```config
140.82.114.4 github.com
```

## 19.5 Access Tokens

`Settings` -> `Developer Settings` -> `Personal access tokens`

You can use token as your password to push to remote repository

## 19.6 How to download a single file from github

```sh
wget https://raw.githubusercontent.com/<user>/<repository>/<branch>/<filepath>
```

## 19.7 Format only modified part

```sh
git diff HEAD -U0 --no-color | clang-format-diff -p1 -i

git diff --name-only HEAD | grep -E '(\.h$)|(\.cpp$)|(\.hpp$)|(\.tpp$)|(\.c$)' | xargs git diff HEAD -U0 --no-color | clang-format-diff -p1 -i
```

# 20 Reference

* [git官方文档](https://git-scm.com/docs/gitignore)
* [git教程](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/)
* [git reset soft,hard,mixed之区别深解](http://www.cnblogs.com/kidsitcn/p/4513297.html)
* [GIT基本概念和用法总结](http://guibin.iteye.com/blog/1014369)
* [常用 Git 命令清单](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)
* [git rebase简介(基本篇)](http://blog.csdn.net/hudashi/article/details/7664631/)
* [git bash中 中文显示为数字](http://blog.csdn.net/zhujiangtaotaise/article/details/74424157)
* [git 合并历史提交](https://www.cnblogs.com/woshimrf/p/git-rebase.html)
* [Configuring diff tool with .gitconfig](https://stackoverflow.com/questions/6412516/configuring-diff-tool-with-gitconfig)
* [寻找并删除 Git 记录中的大文件](https://harttle.land/2016/03/22/purge-large-files-in-gitrepo.html)
* [Mergify](https://docs.mergify.com/)
