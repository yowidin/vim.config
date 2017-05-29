#!/usr/bin/env python3

import  sys, os, shutil

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
print("--- Script path is: '%s'" % SCRIPT_PATH)

HOME_PATH = os.environ['HOME']

# Run a process and throw an exception in case if it doesn't succeed
def run_checked(args, **kwargs):
    import subprocess
    process = subprocess.Popen(args, **kwargs)
    if process.wait() != 0:
        raise Exception("The following command '{0}' has failed".format(' '.join(args)))
    return process

# Create all the necessary directories within the given path
# @param path Full path
def mkdir(path):
    try:
        os.makedirs(path)
        print("--- Created a direcory: '{0}'".format(path))
    except OSError as error:
        import errno
        if error.errno == errno.EEXIST: 
            print("--- Skipped directory creation: '{0}'".format(path))
        else: 
            raise

# Create a symbolik link from this script directory into HOME folder
# for the given path
def symlink(name, directory=''):
    source = os.path.join(SCRIPT_PATH, name)
    target = os.path.join(HOME_PATH, directory, name)
    try:
        os.symlink(source, target)
        print("--- Created a symlink: '{0}' -> '{1}".format(source, target))
    except OSError as error:
        import errno
        if error.errno == errno.EEXIST: 
            print("--- Skipped symlink creation: '{0}' -> '{1}".format(source, target))
        else: 
            raise
    # run_checked(['ln', '-s', os.path.join(SCRIPT_PATH, path), os.path.join(HOME_PATH, path)])
    pass


def main():
    # Create symbolic links
    symlink('.vimrc')
    symlink('.tmux.conf')
    symlink('.zshrc')
    symlink('.Xresources')
    symlink('.clang-format')

    # Prepare the .vim directory
    mkdir(os.path.join(HOME_PATH, '.vim'))

    # Create the rest of symlinks
    symlink('UltiSnips', '.vim')
    symlink('clang-format.py', '.vim')
    symlink('clang-format3.py', '.vim')

    # Prepare Vundle
    vundle_path = os.path.join(HOME_PATH, '.vim', 'bundle', 'Vundle.vim')
    if not os.path.isdir(vundle_path):
        print('--- Checking out the Vundle repository')
        run_checked(['git', 'clone', 'https://github.com/VundleVim/Vundle.vim.git', vundle_path])
    else:
        print('--- Vundle is already checked out')
    run_checked(['vim', '+PluginInstall', '+qall'])
    run_checked(['python', 'install.py', '--clang-completer'], cwd=os.path.join(HOME_PATH, '.vim', 'bundle', 'YouCompleteMe'))

# Main function wrapper - handles all exceptions
# and prints them into standard error output
if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        sys.stderr.write('{0}\n'.format(e))
        sys.exit(1)
