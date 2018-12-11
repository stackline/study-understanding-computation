# frozen_string_literal: true

# Meaning of programming

# [x] Prologue
# [x] 2.1
# [x] 2.2
# [ ] 2.3
#   [ ] 2.3.1
#     [x] 2.3.1.1
#     [x] 2.3.1.2
#     [ ] 2.3.1.3 p.39

require 'pry-byebug'

Number = Struct.new(:value) do
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

Add = Struct.new(:left, :right) do
  def to_s
    "#{left} + #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment) # rubocop:disable Metrics/AbcSize
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end
end

Multiply = Struct.new(:left, :right) do
  def to_s
    "#{left} * #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment) # rubocop:disable Metrics/AbcSize
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end
end

Boolean = Struct.new(:value) do
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

LessThan = Struct.new(:left, :right) do
  def to_s
    "#{left} < #{right}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment) # rubocop:disable Metrics/AbcSize
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

Variable = Struct.new(:name) do
  def to_s
    name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment)
    environment[name]
  end
end

class DoNothing
  def to_s
    'do-nothing'
  end

  def inspect
    "<<#{self}>>"
  end

  def ==(other)
    other.instance_of?(DoNothing)
  end

  def reducible?
    false
  end
end

Assign = Struct.new(:name, :expression) do
  def to_s
    "#{name} = #{expression}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge(name => expression)]
    end
  end
end

If = Struct.new(:condition, :consequence, :alternative) do
  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment)
    if condition.reducible?
      reduced_condition = condition.reduce(environment)
      [If.new(reduced_condition, consequence, alternative), environment]
    else
      case condition
      when Boolean.new(true) then [consequence, environment]
      when Boolean.new(false) then [alternative, environment]
      end
    end
  end
end

Sequence = Struct.new(:first, :second) do
  def to_s
    "#{first}; #{second}"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment)
    case first
    when DoNothing
      [second, environment]
    else
      reduced_first, reduced_environment = first.reduce(environment)
      [Sequence.new(reduced_first, second), reduced_environment]
    end
  end
end

While = Struct.new(:condition, :body) do
  def to_s
    "while (#{condition}) { #{body} }"
  end

  def inspect
    "<<#{self}>>"
  end

  def reducible?
    true
  end

  def reduce(environment)
    consequence = Sequence.new(body, self)
    alternative = DoNothing.new
    [If.new(condition, consequence, alternative), environment]
  end
end

# `Kernel.#puts` internally call `to_s` method.
# Interpolation internally calls `to_s` method.
# These two methods expect a string.
#
# ref. https://stackoverflow.com/questions/25488902/what-happens-when-you-use-string-interpolation-in-ruby/25491660?stw=2#25491660
Machine = Struct.new(:statement, :environment) do
  def run
    while statement.reducible?
      puts "#{statement}, #{environment}"
      step
    end
    puts "#{statement}, #{environment}"
  end

  private

  def step
    # You need to specify the `self` receiver when calling the setter method.
    # If you do not specify a `self` receiver,
    # it is interpreted as a local variable declaration.
    #
    # e.g. case with no receiver
    # 1. Evaluate a expression
    #   expression=(expression.reduce)
    # 2. Declare an `expression` variable that is nil
    # 3. Execute `expression.reduce` as `nil.reduce`
    # 4. NoMethodError occurs
    self.statement, self.environment = statement.reduce(environment)
  end
end
