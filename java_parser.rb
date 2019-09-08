require 'rubygems'
require 'rparsec'

include RParsec::Parsers

require_relative "seq"

class Annotation
  def initialize(name)
    @name = name
  end

  def to_s
    "@" + @name
  end
end

class Variable
  @@variables = []
  def self.variables
    @@variables
  end

  def initialize(annon, name)
    @annon = annon
    @name = name
    @@variables.push self
  end

  def to_s
    [@annon, @name].inspect
  end
end

def parser
  comment_block = seq(string('/*'), not_string('*/').many, string('*/'))
  comment_line = seq(string("//"), not_char(?\n).many, char(?\n).optional)
  space = (regexp("[ \r\n\t]+") | comment_line | comment_block).many
  term = string(";")
  token = regexp("[A-Za-z][A-Za-z0-9_.]*")
  any_token = regexp("[^;]+")
  package = seq(string("package"), space, token, term)
  import =  seq(string("import"), space, token, term)
  imports = seq(import, space).many

  modifier = (string("public") | string("private") | string("protected"))
  modifier_opt = seq(modifier, space).optional
  static = string("static")
  static_opt = seq(static, space).optional
  modifier_static_opt = seq(modifier_opt, static_opt) | seq(static_opt, modifier_opt)

  annotation = 
    sequence(string("@"), token) {|*e| Annotation.new(e[1]) } |
    sequence(string("@"), token, space, string("("), string(")")) {|*e| Annotation.new(e[1]) }

  annotation_opt = seq(annotation, space).many

  type = nil
  lazy_type = lazy { type }
  type_sep_comma = lazy { seq(type, space.optional, string(","), space.optional).many }
  type = token |
         seq(token, string("<"), lazy_type, string(">")) |
         seq(token, string("<"), type_sep_comma, string(">"))

  var_def =
    seq(annotation_opt, modifier_static_opt, type, space, token, space.optional,
                                                                        term) {|*e| Variable.new(e[0], e[4]) } |
    seq(annotation_opt, modifier_static_opt, type, space, token, space.optional, 
                                                string("="), any_token, term) {|*e| Variable.new(e[0], e[4]) }
  method_def = token
  klass_body = (var_def | method_def | space).many
  klass = seq(modifier_opt,
            string("class"),
            space, token, space.optional, string("{"), klass_body, string("}")
          )

  program = seq(package,
                space,
                imports,
                space,
                klass,
                space.optional,
                eof
              )
end

cs = $stdin.read
puts cs
res = parser.parse cs

p res
puts res
require 'pp'
pp Variable.variables
