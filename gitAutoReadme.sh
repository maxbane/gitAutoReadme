#!/bin/bash

# This script is self-documenting! Here are the [autoreadme] config settings (in
# .git/config) used to create the README.md that comes with it:
#
#   [autoreadme]
#   	readme = README.md
#   	sourceglob = *.sh
#       topsentinel = ^OVERVIEW=\"$
#   	bottomsentinel = ^\"$
#       topsentinel = ^USAGE=\"$
#   	bottomsentinel = ^\"$
#       topsentinel = ^LICENSE='$
#   	bottomsentinel = ^'$
#   	includesentinels = false

LICENSE='

License and Copyright
---------------------

Copyright 2011 by Max Bane. Distributed under the terms of the [Creative Commons
Attribution 3.0 Unported license] [1].

[1]: http://creativecommons.org/licenses/by/3.0/     "CC BY 3.0"
'

OVERVIEW="
gitAutoReadme
=============

    Version 0.1.0-dev

A git pre-commit hook script that automagically extracts documentation from your
source files into your ``README`` file.

How it works
------------

``gitAutoReadme.sh`` installs itself (either by a copy or a symbolic link) into
your working copy's ``.git/hooks`` directory, and creates an ``[autoreadme]``
section in ``.git/config``, where various options control how it behaves (see
_Configuration_ below for more details).

Whenever you commit a set of changes to your repository, ``gitAutoReadme.sh``
gets invoked before the commit is finalized. It looks through a set of source
files that you have specified for special **sentinel** lines, which you have
also specified, and which surround the blocks of text that should be
automatically extracted and placed into your ``README`` file. Through judicious
definition and ordering of your sentinels, you can arrange for the contents of
the ``README`` file to be collected from many scattered parts of different
source files. It's all about the self-documenting source code, baby!

Installation
------------

Simply obtain a copy of ``gitAutoReadme.sh``, which may be located anywhere on
your system, for example in the working directory of your clone of
``git@github.com:maxbane/gitAutoReadme.git``. Then, in an interactive shell,
execute:

    $ ./gitAutoReadme.sh -i

You will be walked through an interactive installation process, which you may
cancel at any time. You must answer a series of questions about such things as
the location of the git working copy you want to install to, the desired name of
your ``README`` file, which source files to extract documentation from, and what
sentinel lines to look for. You will also be asked whether the pre-commit hook
should be installed by copying ``gitAutoReadme.sh`` into ``.git/hooks``, or by
creating a symbolic link. The advantage of the latter option is that any changes
to ``gitAutoReadme.sh`` that you subsequently make (you hacker, you) or pull
down from upstream, will immediately take effect.

Configuration
-------------

    TODO

Alternatives
------------

    TODO
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
    echo "[^BEGIN README$]"
    read -e TOPSENTINEL
    if [ -z "$TOPSENTINEL" ]; then
        TOPSENTINEL="^BEGIN README$"
    fi
    #echo "TOP SENTINEL:"
    #echo -ne "\t"
    #echo "$TOPSENTINEL"

    # BOTTOMSENTINEL
    echo
    echo "Enter a \"bottom sentinel\", which source files will use to mark the"
    echo "end of text to be included in the README. You can add more bottom"
    echo "sentinels later with \"git config --add autoreadme.bottomsentinel\"."
    echo "[^END README$]"
    read -e BOTTOMSENTINEL
    if [ -z "$BOTTOMSENTINEL" ]; then
        BOTTOMSENTINEL="^END README$"
    fi
    #echo "BOTTOM SENTINEL:"
    #echo -ne "\t"
    #echo "$BOTTOMSENTINEL"

    # INCLUDESENTINELS
    echo
    echo "Should the sentinels lines themselves be included in the README? [n]"
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

function uninstall {
    cd $1 && \
    rm -f .git/hooks/gitAutoReadme.sh && \
    git config --remove-section autoreadme
}

# Usage info used by -h
USAGE="

Invocation
----------

    gitAutoReadme.sh [ -h | -i | -u gitroot ]

Once installed to your working copy of a repository, you normally don't need to
invoke ``gitAutoReadme.sh`` itself, as that will be handled by a pre-commit hook.
The exceptions are:

  - Initially installing gitAutoReadme on a working copy: 

        ./gitAutoReadme.sh -i

    This process is interactive in the terminal, and is described in the
    _Installation_ section of the documentation.

  - Uninstalling gitAutoReadme from a working copy: 

        ./gitAutoReadme.sh -u /path/to/working/copy

    This will remove the ``gitAutoReadme.sh`` link/copy in the given working
    copy's ``.git/hooks'' directory, and remove the ``[autoreadme]`` section
    from its ``.git/config`` file.

  - Manually running gitAutoReadme to generate the resulting ``README`` file
    without peforming a commit:

        ./gitAutoReadme.sh

  - Finally, invoking ``./gitAutoReadme.sh -h`` prints this _Invocation_ section
    of the documention to standard out and exits.

"

# Check for options
while getopts ":hiu:" opt; do
    case $opt in
        h) echo "$USAGE" | head -n -2 | tail -n +2; 
            exit 0;;
        i) install; exit 0;;
        u) uninstall $OPTARG; exit 0;;
        \?) echo "$0: Unknown option: -$OPTARG" >&2;
            exit 1;;
    esac
done

### From here on down: assume we've been exec'd as part of the pre-commit hook

ME="gitAutoReadme"

# Name of the README file
README="$(git config autoreadme.readme)"
SOURCEGLOBS="$(git config --get-all autoreadme.sourceglob)"
TOPSENTINELS="$(git config --get-all autoreadme.topsentinel)"
BOTTOMSENTINELS="$(git config --get-all autoreadme.bottomsentinel)"
INCLUDESENTINELS="$(git config autoreadme.includesentinels)"

if [ -z "$SOURCEGLOBS" ]; then
    echo "$ME: Error: No source globs specified in config!"
    exit 1;
fi

if [ -z "$TOPSENTINELS" ]; then
    echo "$ME: Error: No top sentinels specified in config!"
    exit 1;
fi

IFS='
'
tops=($TOPSENTINELS)
bots=($BOTTOMSENTINELS)
unset IFS

if [ ${#tops[*]} != ${#bots[*]} ]; then
    echo "$ME: Error: Number of top sentinels (${#tops[*]}) does not equal number of"
    echo "bottom sentinels (${#bots[*]})!"
    exit 1
fi

if [ -z $README ]; then
    echo "$ME: No README filename specified (git config autoreadme.readme)."
    echo "$ME: Using default \"$DEFAULT_README\""
    README="$DEFAULT_README"
fi

# clear out the readme
cp "${README}" "${README}.old" 2> /dev/null
echo -n > "${README}"

# main loop; process each sentinel pair in the order listed in .git/config
i=0
while (($i < ${#tops[*]})); do
    top=${tops[$i]}
    bot=${bots[$i]}
    text=$(sed -n "/${top}/,/${bot}/p" $SOURCEGLOBS 2> /dev/null)
    if [ "$INCLUDESENTINELS" != "true" ]; then
        text=$(echo "$text" | sed -e "/${top}/d" -e "/${bot}/d")
    fi

    if [ ! -z "$text" ]; then
        echo "$ME: ${top} ... ${bot} > ${README}"
        echo "$text" >> "$README"
    else
        echo "$ME: Not found: ${top} ... ${bot}"
    fi

    ((i++))
done

exit 0
