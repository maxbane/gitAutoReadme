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

Usage
-----

Once ``gitAutoReadme`` is installed on your project's working copy and
configured to your liking, simply make commits as normal! ``gitAutoReadme`` will
print a line for each sentinel that it searches for, indicating whether or not
it was found in any source file. For example, here's what it looks like when
making a commit to ``gitAutoReadme``'s own repository:

    $ git commit -am 'More docs, tweaks.'
    gitAutoReadme: ^OVERVIEW=\"$ ... ^\"$ > README.md
    gitAutoReadme: ^USAGE=\"$ ... ^\"$ > README.md
    gitAutoReadme: ^LICENSE='$ ... ^'$ > README.md
    [master f20d76e] More docs, tweaks.
     2 files changed, 208 insertions(+), 15 deletions(-)
    
You can manually bypass all pre-commit hooks, including ``gitAutoReadme``, by
using the ``--no-verify`` option of ``git commit.``

Alternatives
------------

    TODO

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

  - Uninstalling ``gitAutoReadme`` from a working copy: 

        ./gitAutoReadme.sh -u /path/to/working/copy

    This will remove the ``gitAutoReadme.sh`` link/copy in the given working
    copy's ``.git/hooks`` directory, and remove the ``[autoreadme]`` section
    from its ``.git/config`` file.

  - Manually running gitAutoReadme to generate the resulting ``README`` file
    without peforming a commit:

        ./gitAutoReadme.sh

  - Finally, invoking ``./gitAutoReadme.sh -h`` prints this _Invocation_ section
    of the documention to standard out and exits.

License and Copyright
---------------------

Copyright 2011 by Max Bane. Distributed under the terms of the [Creative Commons
Attribution 3.0 Unported license] [1].

[1]: http://creativecommons.org/licenses/by/3.0/     "CC BY 3.0"
