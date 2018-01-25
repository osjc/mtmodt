!!! IMPORTANT WARNING - READ THIS FIRST !!!
===========================================

!!! THIS PROJECT'S MASTER BRANCH IS BEING EXTENSIVELY REBASED !!!

DO NOT YET ATTEMPT TO FORK IT AND DO ANY SIGNIFICANT DEVELOPMENT ON IT. IF
YOU DO, YOU WILL END UP FACING ALL THE PROBLEMS THAT A REBASED UPSTREAM COULD
BRING TO YOU.

!!! YOU HAVE BEEN WARNED !!!

MineTest MOD Tester
===================

.. contents::
   :local:

Introduction
------------

This program and framework aims to allow people that create Minetest mods or
subgames to provide tests for their mods and subgames and other people that
intend to use these to run these tests and see for themselves whether the
mods and subgames are working as intended or not.

The idea is that the subgame or mod provides a set of testcases in a "tests"
directory with a well defined structure, located at the root subdirectory of
his project. The user of that project then can run "mtmodt" command anywhere
inside the tree and the program will execute all of the tests and report any
findings and a short summary. The developer can also run "mtmodt
<some-test-name>" which will run only the test specified. That facility is
useful to run iteratively as the developer is changing some functionality
in her mod.

Hacking
-------

To start tinkering with the code, create a fork of the repository on your
GitHub account. Once you `get something presentable
<doc/manual.rst#contributing>`_, put it into a separate topic branch, push
that branch to your fork and then create a GitHub Pull request out of that
branch. Base your work only on the master branch, any random topic branches
you find in the upstream repository are subject to change and deletion. See
also `the full discussion in the manual
<doc/manual.rst#contributing-to-the-project>`_.

Copyright and License
---------------------

Copyright (C) 2018 Jozef Behran

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License (see the
LICENSE file for its text), or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License,
version 3 along with this program (see the LICENSE file). If not
(the LICENSE file is missing or corrupt), see
<http://www.gnu.org/licenses/>.
