# Meaning of programming

# [x] Prologue
# [x] 2.1
# [x] 2.2
# [ ] 2.3
#   [ ] 2.3.1
#   [ ] 2.3.1.1 p.24

require 'pry-byebug'

# reduce
ret = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reduce do |x, y|
  x + y
end
p ret

# expression
puts "\n### expression\n"

class Number < Struct.new(:value)
  def to_s
    value.to_s
  end

  def inspect
    "<<#{self}>>"
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end
end

add = Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)
# Internally call `#inspect` and call `#to_s` and expect a string.
# ref. https://stackoverflow.com/questions/25488902/what-happens-when-you-use-string-interpolation-in-ruby/25491660?stw=2#25491660
p add
p Number.new(5)
