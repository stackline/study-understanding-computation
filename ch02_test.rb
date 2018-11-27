# frozen_string_literal: true

require_relative 'ch02'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class TestMachine < Minitest::Test
  EXPECTED_ADD_MULTIPLY_OUTPUT = <<~REDUCTION_STEP
    1 * 2 + 3 * 4
    2 + 3 * 4
    2 + 12
    14
  REDUCTION_STEP

  def test_run_add_and_multiply
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    assert_output(EXPECTED_ADD_MULTIPLY_OUTPUT) { Machine.new(expression).run }
  end

  EXPECTED_LESS_THAN_OUTPUT = <<~REDUCTION_STEP
    5 < 2 + 2
    5 < 4
    false
  REDUCTION_STEP

  def test_run_less_than
    expression = LessThan.new(
      Number.new(5),
      Add.new(Number.new(2), Number.new(2))
    )
    assert_output(EXPECTED_LESS_THAN_OUTPUT) { Machine.new(expression).run }
  end

  EXPECTED_VARIABLE_OUTPUT = <<~REDUCTION_STEP
    x + y
    3 + y
    3 + 4
    7
  REDUCTION_STEP

  def test_run_variable
    expression = Add.new(Variable.new(:x), Variable.new(:y))
    environment = { x: Number.new(3), y: Number.new(4) }
    assert_output(EXPECTED_VARIABLE_OUTPUT) do
      Machine.new(expression, environment).run
    end
  end
end
