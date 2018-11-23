# frozen_string_literal: true

# Meaning of programming

# [x] Prologue
# [x] 2.1
# [x] 2.2
# [ ] 2.3
#   [ ] 2.3.1
#   [ ] 2.3.1.1 p.28

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

  def reduce # rubocop:disable Metrics/AbcSize
    if left.reducible?
      Add.new(left.reduce, right)
    elsif right.reducible?
      Add.new(left, right.reduce)
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

  def reduce # rubocop:disable Metrics/AbcSize
    if left.reducible?
      Multiply.new(left.reduce, right)
    elsif right.reducible?
      Multiply.new(left, right.reduce)
    else
      Number.new(left.value * right.value)
    end
  end
end

# `Kernel.#puts` internally call `to_s` method.
# Interpolation internally calls `to_s` method.
# These two methods expect a string.
#
# ref. https://stackoverflow.com/questions/25488902/what-happens-when-you-use-string-interpolation-in-ruby/25491660?stw=2#25491660
Machine = Struct.new(:expression) do
  def run
    while expression.reducible?
      puts expression
      step
    end
    puts expression
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
    self.expression = expression.reduce
  end
end
