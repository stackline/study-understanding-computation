# frozen_string_literal: true

require_relative 'ch02'
require 'pry-byebug'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class TestMachine < Minitest::Test
  EXPECTED_ADD_MULTIPLY_OUTPUT = <<~REDUCTION_STEP
    x = 1 * 2 + 3 * 4, {}
    x = 2 + 3 * 4, {}
    x = 2 + 12, {}
    x = 14, {}
    do-nothing, {:x=><<14>>}
  REDUCTION_STEP

  def test_run_add_and_multiply
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    statement = Assign.new(:x, expression)
    environment = {}
    assert_output(EXPECTED_ADD_MULTIPLY_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_LESS_THAN_OUTPUT = <<~REDUCTION_STEP
    x = 5 < 2 + 2, {}
    x = 5 < 4, {}
    x = false, {}
    do-nothing, {:x=><<false>>}
  REDUCTION_STEP

  def test_run_less_than
    expression = LessThan.new(
      Number.new(5),
      Add.new(Number.new(2), Number.new(2))
    )
    statement = Assign.new(:x, expression)
    environment = {}
    assert_output(EXPECTED_LESS_THAN_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_VARIABLE_OUTPUT = <<~REDUCTION_STEP
    x = x + y, {:x=><<3>>, :y=><<4>>}
    x = 3 + y, {:x=><<3>>, :y=><<4>>}
    x = 3 + 4, {:x=><<3>>, :y=><<4>>}
    x = 7, {:x=><<3>>, :y=><<4>>}
    do-nothing, {:x=><<7>>, :y=><<4>>}
  REDUCTION_STEP

  def test_run_variable
    expression = Add.new(Variable.new(:x), Variable.new(:y))
    statement = Assign.new(:x, expression)
    environment = { x: Number.new(3), y: Number.new(4) }
    assert_output(EXPECTED_VARIABLE_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_ASSIGN_OUTPUT = <<~REDUCTION_STEP
    x = x + 1, {:x=><<2>>}
    x = 2 + 1, {:x=><<2>>}
    x = 3, {:x=><<2>>}
    do-nothing, {:x=><<3>>}
  REDUCTION_STEP

  def test_run_assign
    expression = Add.new(Variable.new(:x), Number.new(1))
    statement = Assign.new(:x, expression)
    environment = { x: Number.new(2) }
    assert_output(EXPECTED_ASSIGN_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_IF_OUTPUT = <<~REDUCTION_STEP
    if (x) { y = 1 } else { y = 2 }, {:x=><<true>>}
    if (true) { y = 1 } else { y = 2 }, {:x=><<true>>}
    y = 1, {:x=><<true>>}
    do-nothing, {:x=><<true>>, :y=><<1>>}
  REDUCTION_STEP

  def test_run_if
    statement = If.new(
      Variable.new(:x),
      Assign.new(:y, Number.new(1)),
      Assign.new(:y, Number.new(2))
    )
    environment = { x: Boolean.new(true) }
    assert_output(EXPECTED_IF_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_IF_WITHOUT_ELSE_OUTPUT = <<~REDUCTION_STEP
    if (x) { y = 1 } else { do-nothing }, {:x=><<false>>}
    if (false) { y = 1 } else { do-nothing }, {:x=><<false>>}
    do-nothing, {:x=><<false>>}
  REDUCTION_STEP

  def test_run_if_without_else
    statement = If.new(
      Variable.new(:x),
      Assign.new(:y, Number.new(1)),
      DoNothing.new
    )
    environment = { x: Boolean.new(false) }
    assert_output(EXPECTED_IF_WITHOUT_ELSE_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end
end
