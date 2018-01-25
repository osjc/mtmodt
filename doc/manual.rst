MineTest MOD Tester - User And Developer Manual
===============================================

.. contents::

Introduction
============

The Minetest MOD Tester (or mtmodt for short) program creates a "simulated
Minetest environment" and then allows the developer to load parts of the mods
or subgames and exercise their functionality using simple Lua files as
testcases. This Minetest environment simulation aims at the speed of
execution and the user convenience over the manual testing with Minetest
itself.

.. note:: Albeit this program is called "MineTest MOD Tester", it can also be
          used to test Minetest Subgames. From now on whenever "mod" is
          mentioned in the text, it refers to subgames as well unless the
          text states otherwise.

Motivation
----------

Minetest requires several seconds to start up the mod which quickly
becomes tedious when a complicated functionality requires dozens of test
runs just to get right. Additionally, Minetest always runs the mod from
the beginning of the subgame it is located in so sometimes significant manual
clicking is needed to exercise the desired functionality within the desired
situation. This explodes to a much bigger problem when the tested
functionality in the mod is not supposed to be available from the start of
the subgame, is expected to differ in different subgames or is triggered
only under certain special conditions. Using Minetest under these
circumstances means the developer needs to keep around dozens of worlds
running different subgames and at different situations and also keep backups
of these worlds so they can be restored if a broken functionality in the mod
renders the world unplayable or brings it into a state where a retest of the
same functionality would require significant involvement.

All of these problems mean that regression testing on Minetest mods is rarely
done. Typically, changed versions of the mods are just posted onto the
release channel and the developer(s) then wait for user complaints. This
means that subtle bugs that are difficult or tricky to trigger are often left
unfixed for significant periods of time and functionality tends to be removed
from the mod if it gets complex enough to enable it to harbor such bugs,
especially if that bugs have immersion breaking effect or they break the
game completely. This removal of the features is almost guaranteed if the
players trip over a subtle game-breaking bug often.

Why I created mtmodt
--------------------

I hit these problems with a full barrel while developing Minetest Saturn.
The `Minetest Saturn <https://github.com/Foghrye4/minetest_saturn>`_ is a
minetest subgame which modifies the minetest gameplay to create a
scientifically quite accurate spaceship simulation. The modifications of the
Minetest gameplay are way more extensive than a typical minetest subgame
would dare to do. The subgame creates a "zero gravity environment" with the
world filled with rocks and asteroids (composed mainly of ice), player gets
damaged when he bumps into things, space stations are introduced that allow
the player to buy and sell stuff and upgrade his kit, this kit includes
combat equipment and there are also enemy spaceships to fight with (though
not at the place where the player starts so he is not dragged into combat
when not ready yet) and the list goes on and on. The end result is a Minetest
subgame whose gameplay is unlike any other Minetest subgame gameplay.

When i saw this, I got pretty intrigued by how it differed from
the typical minecraft-like gameplay and, being an `Elite
<https://en.wikipedia.org/wiki/Elite_(video_game)>`_ and more recently
`Oolite <http://www.oolite.org/>`_ fan, I sinked quite a few hours into
playing this subgame. And, indeed, soon I started to bump into bugs and even
hit the occassional crash. But to be honest, for a subgame with only 14
commits in its history (although it is unclear what is in the history behind
the "initial commit" as it turns out to be pretty large and appears to have
most of the elements of the game) performed pretty admirably, especially
given the fact that the resulting gameplay is so different from the typical
Minecraft.

I got annoyed by the bugs and unfinished features very quickly, so I
`created a fork of it <https://github.com/osjc/minetest_saturn>`_ and started
to fix these bugs and tinkering with the unfinished features. Soon my head
started to bubble with a lot of ideas that I wanted to implement. Many of
these were not so simple to implement but I was confident that they could be
brought to reality someday and I was looking forward to how it would enhance
the gameplay.

However after fixing the most trivial bugs and putting the most trivial
improvements (like better form designs) to place, I ran into a problem.
Minetest has no support for automatic test suites for ite mods nor subgames
and I arrived at a place when I became dissatisfied with the core codebase
of the subgame. My experience says that any type of development with no
ability to add an automatic regression test suite is extremely likely to end
with a grinding halt some six months to one year later. The cause of the halt
is always the same. The number of bugs and regressions, exponentially
increasing with each new change leads to the situation when no progress can
be made because 99% of the time is spent on debugging the same problems over
and over. The net result is that I quickly get bored by doing such a
repetitive and boring work (I can do such a work for extended periods of time
only if i get quite a lot of $$$ per hour for it), lose interest and abandon
the project.

And the fact that Lua is a non-declarative, dynamically typed language did
not help this matter at all. The non-declarative, dynamically typed languages
are typically used only for small glue code pieces written in a couple of
minutes and Lua even advertizes that purpose for itself in its official
documentation. In the Lua book, the `chapter about privacy
<http://www.lua.org/pil/16.4.html>`_ it states:

    Lua is not intended for building huge programs, where many programmers
    are involved for long periods. Quite the opposite, Lua aims at small to
    medium programs, usually part of a larger system, typically developed by
    one or a few programmers, or even by non programmers. Therefore, Lua
    avoids too much redundancy and artificial restrictions.

The "redundancy and artificial restrictions" mentioned above (which mainly
refer to a strong static typing system and requirements of declarations[1]_)
is exactly the type of thing that just tends to get in the way when spending
a couple of minutes writing an one page sized piece of glue code but is
practically indispensable when doing huge projects. My experience is that
with the flexibility that comes with the declarationless dynamic typing
that gets checked at runtime only allows for more bugs to hide in the code
and is especially fertile for the subtle, project killing breed of bugs.

.. [1] It is possible to have a strong static typing system without the
   requirement to provide declarations by using type inference to determine
   the types of the variables used from the expressions that get assigned
   to them (and flagging an error if that yields conflicting results). On the
   other side it is also possible to have a requirement to provide
   declarations without a strong typing system by, for example, creating a
   syntax to list variables used in a code block as either local, upvalues or
   global and requiring that each variable must be mentioned in one of these.
   That is why I consider "strong typing system" to be a different
   requirement from "mandatory declarations".

I thus quickly came with an idea that the subgame could have a "tests"
directory with some well-defined structure and have simple Lua scripts that
load the bits and portions of the mod code, create a mock Minetest
environment and then exercise the loaded bits and pieces of the code with
the situations encoded and created by the test case. This idea was reinforced
after some tinkering with Lua that proved that indeed it is possible to
modify the execution environment of a piece of Lua code in ways not possible
in other languages.

Managing these test cases manually and even running them would prove unwieldy
pretty soon as some kind of test infrastructure is needed to create the
mocked up environment, catch any errors and nicely report them. So another
idea came to have a program that would analyze and execute the test cases and
the test cases themselves would contain only the test specific code.
And so MineTest MOD Tester was born.

Invoking mtmodt
===============

The program supports the following command line options:

--help
  Show a quick summary of the usage and available options.

--version
  Show version and licensing information.

Contributing to the project
===========================

The project is publicly hosted in a GitHub repository. Anyone is welcome to
participate in this project. Just fork the repository, tinker with the code
and when you produce something worthwhile, `make the changes presentable
<#contributing>`_, place them onto a branch of your fork and then
create a GitHub pull request from that branch.

Tinkering with the code
-----------------------

The "master" branch is where all of the code that is deemed stable is placed.
Once placed into the master branch, the code will never be rebased. If a bug
in that code is found later or a typo or factual error in the documentation
is discovered, a separate commit fixing the problem will be created.

Along with the "master" branch there can be one or more development branches.
The content of these branches are extensively rebased by the main developer
because that is needed to be able to see that the documentation is right and
its presentation is not broken in any way. The presentation can only be
tested by pushing the "new and improved" version onto github and then load
the resulting page to see how other people are going to see. I hate creating
a litter of half-complete changes because that breaks the git's amazing
bug hunting facility called "bisect" and additionally it just makes the
history look messy and is nearly impossible to review. Hence the need for
continuous rebasing.

If you want to base a work on this project, you should always do so on top
of the "master" branch. Do not attempt to base your work on another branch
of this repository if you are not `prepared to deal with the problems
stemming from an upstream history that changes
<https://git-scm.com/book/en/v2/Git-Branching-Rebasing>`_. That document
warns repository operators against "rebasing commits that exist somewhere
else":

    When you rebase stuff, you're abandoning existing commits and creating
    new ones that are similar but different. If you push commits somewhere
    and others pull them down and base work on them, and then you rewrite
    those commits with git rebase and push them up again, your collaborators
    will have to re-merge their work and things will get messy when you try
    to pull their work back into yours.

So, if you don't want to he that "collaborator that has to re-merge their
work over and over again" and then "clean it up when things become messy",
base your work off the "master" branch.

Contributing
------------

Here are the rules that all commits placed into the master branch must
follow. They might seem to be quite old school but these work quite well for
me and as I am going to spend most of the time needed to develop this, I need
the code to be in a form that I can work best with.

1. Each commit should come with a detailed commit message written in English.
   The subject line must state the main idea of the change and the
   detailed message shall explain why the change was needed and how it
   accomplished its mission. Do not state implied things like "all use sites
   of this facility were updated" or "the documentation was updated" unless
   there was something notable in these changes that you want to put into the
   commit message. The core of the change must be explained in one or at most
   a few paragraphs but it is okay to include a very long commit message if
   explaining the problem itself clearly takes a long piece of text. Do not
   rely on the changes themselves to be "self-descibing" because the
   rationale of this rule is that given the command "git log --reverse"
   (which shows only the commits and their full messages without any change
   details) one should get a picture of what was happening with the code and
   why by reading just the output.

2. Make the subject line (the first line of the commit message) shorter than
   50 characters and the message content itself narrower than 65 characters
   per line. In the subject line it is OK to omit English syntactic sugar
   like the "a" and "the" little words in order to fit it into 50 characters
   or less but the line must still feel like a valid English sentence. The
   rationale for this is that many of us are using 80 column terminals to do
   the development so they can see other things beside the terminal window at
   the same time. Some git commands like "git log" prepend various data to
   the subject line and indent the message text so the resulting lines shall
   still fit onto an 80 column screen without the need for side scrolling.

3. All of the documentation must be written in the `reStructuredText
   <http://docutils.sourceforge.net/rst.html>`_ format. Section and
   subsection headers must contain only digits, letters and spaces (no
   punctuation). This is because of an extension used here about how to link
   to a section located in another reStructuredText file: use the `syntax for
   external links with embedded URIs and aliases
   <http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#
   embedded-uris-and-aliases>`_ but put the link in the format
   "relative/to/current/document/otherdocument.rst#referenced-section" into
   the angle brackets of the link instead of an URI. The "referenced section"
   part is optional if you want to refer to the document itself and is formed
   by making all letters of the target section header lowercase and replacing
   spaces with dashes. This syntax works for GitHub (it generates a valid
   hyperlink that leads to the place specified), is more readable than the
   standard reStructuredText links and allows you to specify your own
   hyperlink anchor text.

4. All of the lines of the code and documentation source must fit into 77
   characters or less. The rationale is that various development tools used
   by the main developer need that 3 extra columns for various indicators and
   other things so keeping them free allows the complete source being seen
   and edited without that annoying side scrolling effect.

5. The requirement 4 means that the indentation of the blocks in the code
   files is only 2 spaces. Do not use tabs to indent anything and do not
   introduce indentation of more than 2 spaces as this makes the code look
   rather ugly with the left half of the screen mostly empty most of the
   time.

6. Each commit must contain a complete, small and self-contained change to
   the sources along with the accompanying changes to the documentation, if
   any are needed. Hint: If you can't explain the main idea of the change in
   50 characters of the subject line, then the change is too large for a
   single commit (or you might need to learn how to explain yourself
   concisely). If your commit message can't explain the detail of the core
   of the change in a couple of paragraphs, then the change is too big for a
   single commit.

7. Formatting changes must not be mixed in with code changes. Make a separate
   commit for these. Mark its subject line by prepending "Formatting:" to it
   and leave the rest of the commit message empty. Have in mind, though, that
   formatting changes are frowned upon; it is best to just avoid them by
   squashing them into the commits introducing the misformatted code.
   Additionally, avoid reformatting the documentation files unless their
   formatting is horribly broken and squash any reformatting changes
   triggered by your documentation changes into the commit that introduced
   these changes.

8. Code refactoring must not be mixed in with addition of a new feature or
   fixing a bug unless that new feature or the new bug fix absolutely
   requires the refactoring change. Hint: More ofthen than not the
   refactoring change or a significant portion thereof can be factored out
   into a separate self-contained change or even multiple separate
   self-contained changes.

9. This project comes with a test suite. Any new code must be exercised by at
   least one of the test cases. This implies that if you are introducing new
   functionality, you should supply new test cases. Additionally, any changes
   to the code shall not break any tests.

However if your changes don't meet the criteria outlined above and especially
if you are unsure how to accomplis, you are still encouraged to publish them
and advertise their presence to me (or other developers if any). We can work
together to get your change merged.

To submit your changes first collect them into a branch. Use CamelCase
convention (with first letter of the name being a capital letter) for the
name and have the name convey the general idea permeating throughout all the
changes, like AdvancedFurnace (for a branch that adds an advanced version of
a furnace into a minetest subgame). Rebase that branch onto the current
master of the upstream and then push the branch into your fork on GitHub.
That will allow you to create a pull request with your changes where the
changes can be discussed and eventually pulled.

Even after the pull request is created, it is still possible for you to
rework the commits and push the new version of the changeset (use "git push
--force" for that); doing so will directly update the pull request.

However this works only for pull requests that are still open. If you had to
retract your pull request by closing it, you have to reopen it before pushing
the improving version. If you push the improved version first, you won't be
able to reopen the pull request; you will be required to repush the original
version of the commits as seen in the pull request into its branch (also seen
in the pull request; take heed to not lose your improved version in the
process) and then reopen the pull request before putting the new version back
into the branch.
