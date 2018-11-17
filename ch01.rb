# frozen_string_literal: true

# Around Ruby
#
# [x] 1.1
# [x] 1.2
# [x] 1.3
# [x] 1.4
# [x] 1.5
# [x] 1.6

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

puts "\n##### 1.6"

p greeting = 'hello'
p greeting

# rubocop:disable Style/ParallelAssignment
p((width, height, depth = [1000, 2250, 250]))
# rubocop:enable Style/ParallelAssignment
p width, height, depth

p "hello #{'dlrow'.reverse}"

o = Object.new
p def o.to_s
  'a new object'
end
p "here is #{o}"

p o = Object.new
p def o.inspect
  '[my object]'
end
p o

p x = 128
p(
  while x < 1000
    puts "x is #{x}"
    x *= 2
  end
)

p def join_with_commas(*words)
  words.join(', ')
end
p join_with_commas('one', 'two', 'three')

# rubocop:disable Lint/DuplicateMethods
p def join_with_commas(before, *words, after)
  before + words.join(', ') + after
end
# rubocop:enable Lint/DuplicateMethods
p join_with_commas('Testing: ', 'one', 'two', 'three', '.')

p arguments = ['Testing: ', 'one', 'two', 'three', '.']
p join_with_commas(*arguments)

p((before, *words, after = ['Testing: ', 'one', 'two', 'three', '.']))
p before
p words
p after

p def do_three_times
  yield
  yield
  yield
end
do_three_times { puts 'hello' }

p def do_three_times_with_block_parameter
  yield('first')
  yield('second')
  yield('third')
end
p(do_three_times_with_block_parameter { |n| puts "#{n}: hello" })

p def number_names
  [yield('one'), yield('two'), yield('three')].join(', ')
end
p(number_names { |name| name.upcase.reverse })

p((1..10).count(&:even?))
p((1..10).select(&:even?))
p((1..10).any? { |number| number < 8 })
p((1..10).all? { |number| number < 8 })
p(
  (1..5).each do |number|
    if number.even?
      puts "#{number} is even"
    else
      puts "#{number} is odd"
    end
  end
)
p((1..10).map { |number| number * 3 })
p(%w[one two three].map(&:upcase))
p(%w[one two three].map(&:chars))
p(%w[one two three].flat_map(&:chars))
p((1..10).inject(0) { |result, number| result + number })
p((1..10).inject(1) { |result, number| result * number })
p(%w[one two three].inject('Words:') { |result, word| "#{result} #{word}" })

class Point < Struct.new(:x, :y) # rubocop:disable Style/StructInheritance
  def +(other)
    Point.new(x + other.x, y + other.y)
  end

  def inspect
    "#<Point (#{x}, #{y})>"
  end
end
p a = Point.new(2, 3)
p b = Point.new(10, 20)
p a + b
p a.x
p a.x = 35
p a + b

p Point.new(4, 5) == Point.new(4, 5) # rubocop:disable Lint/UselessComparison
p Point.new(4, 5) == Point.new(6, 7)

p class Point
    def -(other)
      Point.new(x - other.x, y - other.y)
    end
  end
p Point.new(10, 15) - Point.new(1, 1)

p class String
    def shout
      upcase + '!!!'
    end
  end
p 'hello world'.shout

p NUMBERS = [4, 8, 15, 16, 23, 42].freeze
p NUMBERS

p class Greetings
    ENGLISH = ' hello'.freeze
    FRENCH = 'bonjour'.freeze
    GERMAN = 'guten Tag'.freeze
  end
p NUMBERS.last
p Greetings::FRENCH

p NUMBERS.last
p Object.send(:remove_const, :NUMBERS)
# p NUMBERS.last
p Greetings::GERMAN
p Object.send(:remove_const, :Greetings)
# p Greetings::GERMAN

p NUM_CONST = [1, 2, 3].freeze
# p Object.send(:remove_const, :NUM_CONST)
p Object.constants.grep(:NUM_CONST)

# memo
puts "\n##### memory reference"
class Test; end
test = Test.new
p test
p((test.object_id << 1).to_s(16))
p((test.object_id * 2).to_s(16))

puts "\n##### freeze"
p test1 = [1].freeze
p test1.frozen?

# p test1[0] = 'foo'
# p test1

test2 = test1.dup
p test2
p test2.frozen?

test2[0] = 'foo'
p test2
