# frozen_string_literal: true

require_relative 'ch02'
require 'pry-byebug'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class TestMachine < Minitest::Test # rubocop:disable Metrics/ClassLength
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

  EXPECTED_SEQUENCE_OUTPUT = <<~REDUCTION_STEP
    x = 1 + 1; y = x + 3, {}
    x = 2; y = x + 3, {}
    do-nothing; y = x + 3, {:x=><<2>>}
    y = x + 3, {:x=><<2>>}
    y = 2 + 3, {:x=><<2>>}
    y = 5, {:x=><<2>>}
    do-nothing, {:x=><<2>>, :y=><<5>>}
  REDUCTION_STEP

  def test_run_sequence
    first = Assign.new(:x, Add.new(Number.new(1), Number.new(1)))
    second = Assign.new(:y, Add.new(Variable.new(:x), Number.new(3)))
    statement = Sequence.new(first, second)
    environment = {}
    assert_output(EXPECTED_SEQUENCE_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_WHILE_OUTPUT = <<~REDUCTION_STEP
    while (x < 5) { x = x * 3 }, {:x=><<1>>}
    if (x < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<1>>}
    if (1 < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<1>>}
    if (true) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<1>>}
    x = x * 3; while (x < 5) { x = x * 3 }, {:x=><<1>>}
    x = 1 * 3; while (x < 5) { x = x * 3 }, {:x=><<1>>}
    x = 3; while (x < 5) { x = x * 3 }, {:x=><<1>>}
    do-nothing; while (x < 5) { x = x * 3 }, {:x=><<3>>}
    while (x < 5) { x = x * 3 }, {:x=><<3>>}
    if (x < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<3>>}
    if (3 < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<3>>}
    if (true) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<3>>}
    x = x * 3; while (x < 5) { x = x * 3 }, {:x=><<3>>}
    x = 3 * 3; while (x < 5) { x = x * 3 }, {:x=><<3>>}
    x = 9; while (x < 5) { x = x * 3 }, {:x=><<3>>}
    do-nothing; while (x < 5) { x = x * 3 }, {:x=><<9>>}
    while (x < 5) { x = x * 3 }, {:x=><<9>>}
    if (x < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<9>>}
    if (9 < 5) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<9>>}
    if (false) { x = x * 3; while (x < 5) { x = x * 3 } } else { do-nothing }, {:x=><<9>>}
    do-nothing, {:x=><<9>>}
  REDUCTION_STEP

  def test_run_while
    condition = LessThan.new(Variable.new(:x), Number.new(5))
    body = Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3)))
    statement = While.new(condition, body)
    environment = { x: Number.new(1) }
    assert_output(EXPECTED_WHILE_OUTPUT) do
      Machine.new(statement, environment).run
    end
  end

  EXPECTED_INCORRECT_STATEMENT_OUTPUT = <<~REDUCTION_STEP
    x = true; x = x + 1, {}
    do-nothing; x = x + 1, {:x=><<true>>}
    x = x + 1, {:x=><<true>>}
    x = true + 1, {:x=><<true>>}
  REDUCTION_STEP

  def test_run_incorrect_statement
    first = Assign.new(:x, Boolean.new(true));
    second = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
    statement = Sequence.new(first, second)
    environment = {}
    assert_output(EXPECTED_INCORRECT_STATEMENT_OUTPUT) do
      assert_raises NoMethodError do
        Machine.new(statement, environment).run
      end
    end
  end
end
