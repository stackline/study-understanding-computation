# frozen_string_literal: true

require_relative 'ch02'
require 'minitest/autorun'

class TestMachine < Minitest::Test
  EXPECTED_OUTPUT = <<~REDUCTION_STEP
    1 * 2 + 3 * 4
    2 + 3 * 4
    2 + 12
    14
  REDUCTION_STEP

  def setup
    expression = Add.new(
      Multiply.new(Number.new(1), Number.new(2)),
      Multiply.new(Number.new(3), Number.new(4))
    )
    @machine = Machine.new(expression)
  end

  def test_run
    puts "\nMachine#run"
    assert_output(EXPECTED_OUTPUT) { @machine.run }
  end
end
