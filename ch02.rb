# Meaning of programming

# [x] Prologue
# [x] 2.1
# [x] 2.2
# [ ] 2.3
#   [ ] 2.3.1
#   [ ] 2.3.1.1 p.27

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

  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      Add.new(left.reduce, right)
    elsif right.reducible?
      Add.new(left, right.reduce)
    else
      Number.new(left.value + right.value)
    end
  end
end

class Multiply < Struct.new(:left, :right)
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce
    if left.reducible?
      Multiply.new(left.reduce, right)
    elsif right.reducible?
      Multiply.new(left, right.reduce)
    else
      Number.new(left.value * right.value)
    end
  end
end

# Internally call `#inspect` and call `#to_s` and expect a string.
# ref. https://stackoverflow.com/questions/25488902/what-happens-when-you-use-string-interpolation-in-ruby/25491660?stw=2#25491660
expression = Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)
p expression
# => <<1 * 2 + 3 * 4>>
p expression.reducible?

expression = expression.reduce
p expression
# => <<2 + 3 * 4>>
p expression.reducible?

expression = expression.reduce
p expression
# => <<2 + 12>>
p expression.reducible?

expression = expression.reduce
p expression
# => <<14>>
p expression.reducible?

# MEMO: Pass Enumerable#reduce method to an object of Struct Class.
expression = expression.reduce
p expression
# => 14
