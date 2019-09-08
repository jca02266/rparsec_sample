require 'rubygems'
require 'rparsec'

include RParsec::Parsers

require_relative "seq"

def trim_quote(s)
  case s
  when /^"(.*)"$/ then $1
  when /^'(.*)'$/ then $1
  else s
  end
end

def parser(&attribute_proc)
  comment_block = regexp(%r{/<!-- (.*?) -->/}mx)
  space = (regexp("[ \r\n\t]+") | comment_block).many
  token = regexp("[A-Za-z][A-Za-z0-9_.]*")
  text = regexp("[^>]+")


  quoted_value =
    seq(string("'"), regexp("[^']*"), string("'")) |
    seq(string('"'), regexp('[^"]*'), string('"'))

  attribute =
    seq(token, space, string("="), space, quoted_value, &attribute_proc)

  attributes_opt = seq(attribute, space).many


  tag = nil
  tag_lazy = lazy { tag }
  body = tag_lazy | space | text
  tag =
    seq(string("<"), token, space, attributes_opt, string("/>")) |
    seq(string("<"), token, space, attributes_opt, string(">"), body.many, string("</"), token, string(">"))

  html = seq(tag, space).many.plus(eof)
end

cs = $stdin.read
puts cs

res = parser {|*e|
  token = e[0]
  value = trim_quote(e[4])

  p [:attribute, token, value]
}.parse cs

p res
puts res
