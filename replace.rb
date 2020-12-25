#! /usr/bin/ruby
# coding: utf-8

# "abc" + "def" を "abcdef" にする 

regexp = /"(\w+)" \+ "(\w+)"/
replace = '"\1\2"'

ARGV.each {|file|
  buf = File.read(file)
  buf = buf.gsub(regexp, replace)
p buf
  File.rename(file, file + ".bak")
  File.open(file, "w") {|o| o.print buf}
}
