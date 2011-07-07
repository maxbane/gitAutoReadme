gitAutoReadme
=============

    Version 0.1.0

A git pre-commit hook script that automagically extracts documentation from your
source files into your ``README`` file. This ``README`` file itself was
generated from the ``gitAutoReadme.sh`` script, and serves as a working example. 

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

Prerequisities
--------------

Besides ``git``, ``gitAutoReadme`` only depends on a few standard Unix tools
being available: ``bash``, ``cp``, ``ln``, and ``sed``.

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

After running the interactive installation, you will find a new ``[autoreadme]``
section in your ``.git/config`` file. It might look like this (depending on what
you entered during the installation):

    [autoreadme]
        readme = README.md
        sourceglob = *.c
        topsentinel = ^BEGIN README$
        bottomsentinel = ^END README$
        includesentinels = false

You can change these configuration options either by editing the config file
directly, or by using the ``git config`` commad. For example, if you want to add
``*.py`` to the set of source files that get searched for ``README`` content,
you can do this:

    $ git config --add autoreadme.sourceglob '*.py'

And the resulting config file will look like this:

    [autoreadme]
        readme = README.md
        sourceglob = *.c
        topsentinel = ^BEGIN README$
        bottomsentinel = ^END README$
        includesentinels = false
        sourceglob = *.py

The meanings of the options are as follows:

  - ``autoreadme.readme``: The name of the ``README`` file to generate.

  - ``autoreadme.sourceglob``: Each ``sourceglob`` line adds a set of files
  to be searched for sentinels. You can enter anything here that ``bash``'s glob
  or brace expansion will turn into a list of files, relative to the top of your
  working copy.

  - ``autoreadme.topsentinel`` and ``autoreadme.bottomsentinel``: These
  lines must always come in pairs, and the first ``topsentinel`` line in the
  config file is associated with the first ``bottomsentinel`` line, the sencond
  ``topsentinel`` with the second ``bottomsentinel``, and so on. Each pair uses
  ``sed``-style regular expressions to describe which lines of a source file
  should be matched as top and bottom sentinels. Everything between a pair of
  associated top/bottom-sentinel lines is extracted and placed in the ``README``
  file upon a commit. Sentinels are searched for, and any matching text
  extracted, _in the order in which they appear in the config file_. You can
  therefore use different top/bottom-sentinel pairs, arranged in a particular
  order, to put text from all over your source files into your ``README`` in
  whatever order you like.

  - ``includesentinels``: If ``true``, the sentinel lines themselves (in
  addition to the text between them) will be included in the ``README``.

Usage
-----

Once ``gitAutoReadme`` is installed on your project's working copy and
configured to your liking, simply make commits as normal. ``gitAutoReadme`` will
print a line for each sentinel that it searches for, indicating whether or not
it was found in any source file. For example, here's what it looks like when
making a commit to ``gitAutoReadme``'s own repository:

    $ git commit -am 'More docs, tweaks.'
    gitAutoReadme: ^OVERVIEW=\"$ ... ^\"$ > README.md
    gitAutoReadme: ^USAGE=\"$ ... ^\"$ > README.md
    gitAutoReadme: ^LICENSE='$ ... ^'$ > README.md
    [master f20d76e] More docs, tweaks.
     2 files changed, 208 insertions(+), 15 deletions(-)

``gitAutoReadme`` clears your ``README`` file before populating it on each
commit, but first it makes a copy of the existing ``README`` with the ``.old``
suffix..
    
You can manually bypass all pre-commit hooks, including ``gitAutoReadme``, by
using the ``--no-verify`` option of ``git commit.``


Alternatives
------------

Many programming languages provide mechanisms for self-documenting source code,
e.g., Java's javadoc comments, and Python's doc strings. There are also many
tools, like Epydoc, for extracting such documentation from source and producing
full API docs. The design goals of ``gitAutoReadme`` differ from these in
several ways:

  - The focus is on generating a ``README`` file rather than full API docs,
    though you certainly could use ``gitAutoReadme`` to include all of your API
    documentation in the ``README``, if you wanted to.

  - It is completely language-neutral and markup-neutral. It can be used to
    include not just comment strings, but any kind of text from your source
    files, including snippets of live code.

  - It integrates seamlessly into your ``git``-based workflow, and is perfect
    for keeping the ``README`` displayed on your project's github page always
    current. You could even add some more pre-commit hooks of your own, which
    together with ``gitAutoReadme`` might do some pretty complicated
    programmatic ``README``-generation.

``gitAutoReadme`` is also related to so-called _literate programming_ tools like
Sweave, which are generally much more complicated and powerful.
``gitAutoReadme`` offers simplicity, and takes a complementary approach: you
embed your documentation in your code, rather than embedding your code in your
documentation.

Invocation
----------

    gitAutoReadme.sh [ -h | -i | -u gitroot ]

Once installed to your working copy of a repository, you normally don't need to
invoke ``gitAutoReadme.sh`` itself, as that will be handled by a pre-commit hook.
The exceptions are:

  - Initially installing ``gitAutoReadme`` on a working copy: 

        ./gitAutoReadme.sh -i

    This process is interactive in the terminal, and is described in the
    _Installation_ section of the documentation.

  - Uninstalling ``gitAutoReadme`` from a working copy: 

        ./gitAutoReadme.sh -u /path/to/working/copy

    This will remove the ``gitAutoReadme.sh`` link/copy in the given working
    copy's ``.git/hooks`` directory, and remove the ``[autoreadme]`` section
    from its ``.git/config`` file.

  - Manually running ``gitAutoReadme`` to generate the resulting ``README`` file
    without peforming a commit (this must be done from the top of your working
    copy):

        ./.git/hooks/gitAutoReadme.sh

  - Finally, invoking ``./gitAutoReadme.sh -h`` prints this _Invocation_ section
    of the documention to standard out and exits.

License and Copyright
---------------------

Copyright 2011 by Max Bane. Distributed under the terms of the [Creative Commons
Attribution 3.0 Unported license] [1].

[1]: http://creativecommons.org/licenses/by/3.0/     "CC BY 3.0"
