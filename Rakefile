# ---
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
# +++
# 
# Rakefile for project LatexTools
#
#

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'



#----------------
# Gem packaging
#++++++++++++++++
spec = Gem::Specification.new do |s|
    s.name = "latex-tools"
    s.version = "0.1"
    s.has_rdoc = true
    s.extra_rdoc_files = ['README', 'LICENSE']
    s.summary = "Tools for generating Latex code fragments."
    s.description = "The latex-tools gem is a collection of classes that facilitate the writing of various elements of Latex code.  It is not designed for authoring entire Latex files, merely their component parts.  Right now, it only consists of one such 'tool', LatexTable, which provides an easy and convenient way of outputting Latex code for tables from data in a ruby script."
    s.author = "David S. Hollman"
    s.email = "david.s.hollman@gmail.com"
    s.files = %w(LICENSE README Rakefile) + Dir.glob("{lib,test,examples}/**/*")
    s.require_path = "lib"
    s.test_files = Dir.glob("{test}/**/*")
    s.homepage = "http://github.com/dhollman/ruby-latex-tools"
end

Rake::GemPackageTask.new(spec) do |p|
    p.need_tar = true
    p.need_zip = true
end

task :upload => :gem do
  `gem push #{Dir.glob("pkg/latex-tools*.gem")}`
end

#----------------
# Testing
#++++++++++++++++
Rake::TestTask.new do |t|
    t.test_files = FileList['test/**/*_test.rb']
    t.libs << Dir["lib","test/lib"]
end


#----------------
# Code coverage
#++++++++++++++++
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << Dir["lib","test/lib"]
    t.test_files = FileList['test/**/*_test.rb']
    t.verbose = true
  end
rescue LoadError
  # The user doesn't have rcov/rcovtask.  No worries, we just won't make it available
end



#----------------
# Documentation
#++++++++++++++++
Rake::RDocTask.new do |t|
  t.main = "lib/latex_tools.rb"
  t.rdoc_files.include("lib/**/*.rb")
  t.rdoc_dir = 'doc/rdoc/' + spec.version.to_s
end
