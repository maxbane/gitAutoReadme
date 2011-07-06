#!/bin/bash

# Usage info
USAGE="
BEGIN README
gitAutoReadme.sh
================

A git pre-commit hook script that automagically extracts documentation from your
source files into your README file.

Usage TODO.

END README
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
    echo "Enter a \"top sentinel\", which source files will use to mark the"
    echo "beginning of text to be included in the README. You can add more top"
    echo "sentinels later with \"git config --add autoreadme.topsentinel\"."
    echo "[BEGIN README]"
    read -e TOPSENTINEL
    if [ -z "$TOPSENTINEL" ]; then
        TOPSENTINEL="BEGIN README"
    fi
    #echo "TOP SENTINEL:"
    #echo -ne "\t"
    #echo "$TOPSENTINEL"

    # BOTTOMSENTINEL
    echo
    echo "Enter a \"bottom sentinel\", which source files will use to mark the"
    echo "end of text to be included in the README. You can add more bottom"
    echo "sentinels later with \"git config --add autoreadme.bottomsentinel\"."
    echo "[END README]"
    read -e BOTTOMSENTINEL
    if [ -z "$BOTTOMSENTINEL" ]; then
        BOTTOMSENTINEL="END README"
    fi
    #echo "BOTTOM SENTINEL:"
    #echo -ne "\t"
    #echo "$BOTTOMSENTINEL"

    # INCLUDESENTINELS
    echo
    echo "Should the sentinels themselves be included in the README? [n]"
    while [ "$INCLUDESENTINELS" != "y" -a "$INCLUDESENTINELS" != "n" ]; do
        echo -n "Enter \"y\" or \"n\": "
        read -n 1 INCLUDESENTINELS
        echo
        if [ -z "$INCLUDESENTINELS" ]; then
            INCLUDESENTINELS="n"
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

    # copy or link us into the destination hooks dir
    if [ "$COPYORLINK" = "c" ]; then
        cp "$0" "${GITROOT}/.git/hooks"
    elif [ "$COPYORLINK" = "l" ]; then
        ln -sf "$(pwd)/$0" "${GITROOT}/.git/hooks"
    fi

    addedByLine="# Added by gitAutoReadme.sh interactive installation:"
    sourceLine="exec .git/hooks/gitAutoReadme.sh"
    sourceLineRegex="$(echo ${sourceLine} | sed "s/\./\\\./")"
    precommit="${GITROOT}/.git/hooks/pre-commit"
    # if the hooks/pre-commit script already exists, add a line sourcing our
    # copy/link
    if [ -f "${precommit}" ]; then
        grepout="$(grep "${sourceLineRegex}" ${precommit})"
        if [ -z "$grepout" ]; then
            echo "$addedByLine" >> "${precommit}"
            echo "$sourceLine" >> "${precommit}"
        fi
    else
        # otherwise create it
        echo "#!/bin/bash" > "${precommit}"
        echo "$addedByLine" >> "${precommit}"
        echo "$sourceLine" >> "${precommit}"
    fi
    # make sure the pre-commit script is executable
    chmod 755 "${precommit}"

    # setup git config options used by gitAutoReadme
    git config autoreadme.readme "${README}"
    git config autoreadme.sourceglob "${SOURCEGLOB}"
    git config autoreadme.topsentinel "${TOPSENTINEL}"
    git config autoreadme.bottomsentinel "${BOTTOMSENTINEL}"
    if [ "$INCLUDESENTINELS" = "y" ]; then
        INCLUDESENTINELS="true"
    else
        INCLUDESENTINELS="false"
    fi
    git config autoreadme.includesentinels "${INCLUDESENTINELS}"

}

# Check for options
while getopts ":hi" opt; do
    case $opt in
        h) echo "$USAGE" | head -n -2 | tail -n +3; 
            exit 0;;
        i) install; exit 0;;
        \?) echo "$0: Unknown option: -$OPTARG" >&2;
            exit 1;;
    esac
done

### From here on down: assume we've been exec'd as part of the pre-commit hook

# Name of the README file
README="$(git config autoreadme.readme)"
SOURCEGLOB="$(git config autoreadme.sourceglob)"
TOPSENTINEL="$(git config autoreadme.topsentinel)"
BOTTOMSENTINEL="$(git config autoreadme.bottomsentinel)"
INCLUDESENTINELS="$(git config autoreadme.includesentinels)"

if [ -z $README ]; then
    echo "$0: No README filename specified (git config autoreadme.readme)."
    echo "$0: Using default \"$DEFAULT_README\""
    README="$DEFAULT_README"
fi

echo "$0: Wrote $README."

#awk '' gitAutoReadme.sh | head -n-1 > README.md
