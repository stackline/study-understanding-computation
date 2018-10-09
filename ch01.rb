# Around Ruby
#
# [x] 1.1
# [x] 1.2
# [x] 1.3
# [x] 1.4
# [x] 1.5 p.25
# [ ] 1.6

puts '##### 1.1'

p 1 + 2
s = 'hello world'
p s.length

x = 2
y = 3
z = x + y
p x * y * z

puts "\n##### 1.2"

p((true && false) || true)
p((3 + 3) * (14 / 2))
p 'hello' + ' world'
p 'hello world'.slice(6)

p :my_symbol
p :my_symbol == :my_symbol # rubocop:disable Lint/UselessComparison
p :my_symbol == :another_symbol
p 'hello world'.slice(11)

p numbers = %w[zero one two]
p numbers[1]
p numbers.push('three', 'four')
p numbers
p numbers.drop(2)

p ages = 18..30
p ages.entries
p ages.include?(25)
p ages.include?(33)

p fruit = { 'a' => 'apple', 'b' => 'banana', 'c' => 'coconut' }
p fruit['b']
p fruit['d'] = 'date'
# MEMO: `[key]=` is the syntax sugar of the `store` method
# p fruit.[]=('d', 'date')
# p fruit.store('d', 'date')
p fruit

p dimensions = { width: 1000, height: 2250, depth: 250 }
p dimensions[:depth]

p multiply = ->(xx, yy) { xx * yy }
p multiply.call(6, 9)
p multiply.call(2, 3)
p multiply[3, 4]

puts "\n##### 1.3"

p(
  if 2 < 3
    'less'
  else
    'more'
  end
)
quantify = lambda do |number|
  case number
  when 1 then 'one'
  when 2 then 'a couple'
  else 'many'
  end
end
p quantify
p quantify.call(2)
p quantify.call(10)
p x = 1
# while x < 1000
#   x = x * 2
# end
p((x *= 2 while x < 1000))
p x

puts "\n##### 1.4"

o = Object.new
p o
p def o.add(x, y)
  x + y
end
p o.add(2, 3)

p def o.add_twice(x, y)
  add(x, y) + add(x, y)
end
p o.add_twice(2, 3)

p def multiply(a, b)
  a * b
end
p multiply(2, 3)

puts "\n##### 1.5"

p class Calculator
    def divide(x, y)
      x / y
    end
  end

c = Calculator.new
p c
p c.class
p c.divide(10, 2)

p class MultiplyingCalculator < Calculator
    def multiply(x, y)
      x * y
    end
  end

mc = MultiplyingCalculator.new
p mc
p mc.class
p mc.class.superclass
p mc.multiply(10, 2)
p mc.divide(10, 2)

p class BinaryMultiplyingCalculator < MultiplyingCalculator
    def multiply(x, y)
      result = super(x, y)
      result.to_s(2)
    end
  end
bmc = BinaryMultiplyingCalculator.new
p bmc
p bmc.multiply(10, 2)

p module Addition
    def add(x, y)
      x + y
    end
  end
# p class AddingCalculator
#     include Addition
#   end
class AddingCalculator
end
p AddingCalculator.include Addition

ac = AddingCalculator.new
p ac
p ac.add(10, 2)
