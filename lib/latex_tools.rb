#--
# Copyright (c) 2011-2012 David Hollman
# This file is part of the LatexTools rubygem.
#
# The LatexTools rubygem is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# The LatexTools rubygem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser Public License for more details.
#
# You should have received a copy of the GNU Lesser Public License
# along with the LatexTools rubygem.  If not, see <http://www.gnu.org/licenses/>.
#++

##
# Tools for generating Latex code fragments
#
# The latex-tools gem is a collection of classes that facilitate the writing of various elements of Latex code.  It is not designed for authoring entire Latex files, merely their component parts.  Right now, it only consists of one such 'tool', LatexTable, which provides an easy and convenient way of outputting Latex code for tables from data in a ruby script.
#
# ==Installation
# Install the gem just like any other gem:
#   gem install latex-tools
#
#
# ==Documentation Status
# The classes (right now only LatexTable) should be documented well enough to get started, but individual class methods
# are mostly undocumented.  This documentation will (hopefully) be added in the future.
#
# ==The LatexTools module
# The +LatexTools+ module wraps everything in this package.
# For convenience of use (i.e. unless you have a good reason not to do so),
# you should include the following line at the beginning of your source code:
#   include LatexTools
#
# Not doing so will result in much more verbose and much harder to read code, which
# is not how this module was intended to be used.  For instance, when the module is
# included properly, use of the LatexTable class becomes quite clean and "c++ like":
#   :include: examples/table/example1.rb
# (See the LatexTable class documentation for more.)
#
module LatexTools

end
