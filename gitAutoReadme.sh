#!/bin/bash

# Usage info
USAGE="
gitAutoReadme.sh
================

A git pre-commit hook script that automagically extracts documentation from your
source files into your README file.

Usage TODO.

END USAGE
"

# Defaults
DEFAULT_README="README"

# Interactive installation
function install {
    echo "Installation requested. Let's interactively install gitAutoReadme as"
    echo "a pre-commit hook in your git repository. You must answer a few"
    echo "questions -- press CTRL-C at any time before the end to cancel"
    echo "installation. Each question has a default answer indicated in"
    echo "[square brackets]; simply press enter to accept the default."

    # GITROOT
    echo
    echo -n "What is the local path to the root of the git repo? [.] "
    read -e GITROOT
    if [ -z "$GITROOT" ]; then
        GITROOT="."
    fi
    if [ ! -d "$GITROOT" ]; then
        echo "$GITROOT does not exist or is not a directory!"
        exit 1
    fi
    if [ ! -d "${GITROOT}/.git" ]; then
        echo "$GITROOT contains no .git subdirectory!"
        exit 1
    fi

    # README
    echo
    echo -n "Desired name of README file? [README] "
    read -e README
    if [ -z "$README" ]; then
        README=$DEFAULT_README
    fi
    if [ -a "${GITROOT}/${README}" ]; then
        echo "File $README exists. You may want to back it up!"
    fi

    # SOURCEGLOB
    while [ -z "$SOURCEGLOB" ]; do
        echo
        echo "Enter a filename glob describing the source files from which to"
        echo "extract the README contents (e.g., *.c). You can change this later"
        echo "by setting \"git config autoreadme.sourceglob\". You can also add"
        echo "multiple globs with \"git config --add\". [no default]"
        read -e SOURCEGLOB
    done
    SOURCES="$(ls -Ad ${GITROOT}/${SOURCEGLOB})"
    echo "Your glob currently matches $(echo $SOURCES | wc -w) files:"
    echo $SOURCES

    # TOPSENTINEL
    echo
    echo "Enter a \"top sentinal\", which source files will use to mark the"
    echo "beginning of text to be included in the README. You can add more top"
    echo "sentinals later with \"git config --add autoreadme.topsentinal\"."
    echo "[BEGIN README]"
    read -e TOPSENTINAL
    if [ -z "$TOPSENTINAL" ]; then
        TOPSENTINAL="BEGIN README"
    fi
    #echo "TOP SENTINAL:"
    #echo -ne "\t"
    #echo "$TOPSENTINAL"

    # BOTTOMSENTINEL
    echo
    echo "Enter a \"bottom sentinal\", which source files will use to mark the"
    echo "end of text to be included in the README. You can add more bottom"
    echo "sentinals later with \"git config --add autoreadme.bottomsentinal\"."
    echo "[END README]"
    read -e BOTTOMSENTINAL
    if [ -z "$BOTTOMSENTINAL" ]; then
        BOTTOMSENTINAL="END README"
    fi
    #echo "BOTTOM SENTINAL:"
    #echo -ne "\t"
    #echo "$BOTTOMSENTINAL"

    # INCLUDESENTINALS
    echo
    echo "Should the sentinals themselves be included in the README? [n]"
    while [ "$INCLUDESENTINALS" != "y" -a "$INCLUDESENTINALS" != "n" ]; do
        echo -n "Enter \"y\" or \"n\": "
        read -n 1 INCLUDESENTINALS
        echo
        if [ -z "$INCLUDESENTINALS" ]; then
            INCLUDESENTINALS="n"
        fi
    done

    # COPYORLINK
    echo
    echo "$0 must be be placed in ${GITROOT}/.git/hooks -- it may"
    echo "either be copied thereto or symbolically linked therefrom. The"
    echo "advantage of the latter is that any future updates to this copy of"
    echo "the script (say, by pulling new commits from the gitAutoReadme"
    echo "repository) will instantly take effect in any project that uses a"
    echo "symbolic link to it. [l]"
    while [ "$COPYORLINK" != "l" -a "$COPYORLINK" != "c" ]; do
        echo -n "Enter \"c\" or \"l\": "
        read -n 1 COPYORLINK
        echo
        if [ -z "$COPYORLINK" ]; then
            COPYORLINK="l"
        fi
    done

    # ready
    echo
    echo "Press enter to install, or CTRL-C to cancel."
    read

    if [ "$COPYORLINK" = "c" ]; then
        cp "$0" "${GITROOT}/.git/hooks"
    elif [ "$COPYORLINK" = "l" ]; then
        ln -sf "$0" "${GITROOT}/.git/hooks"
    fi
}

# Check for options
while getopts ":hi" opt; do
    case $opt in
        h) echo "$USAGE"; exit 0;;
        i) install; exit 0;;
        \?) echo "$0: Unknown option: -$OPTARG" >&2;
            exit 1;;
    esac
done


# Name of the README file
README="$(git config autoreadme.readme)"

if [ -z $README ]; then
    echo "$0: No README filename specified (git config autoreadme.readme)."
    echo "$0: Using default \"$DEFAULT_README\""
    README="$DEFAULT_README"
fi

echo "$0: Wrote $README."

#awk '' gitAutoReadme.sh | head -n-1 > README.md
