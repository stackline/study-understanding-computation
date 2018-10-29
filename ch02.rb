# Meaning of programming

# [x] Prologue
# [x] 2.1
# [x] 2.2
# [ ] 2.3
#   [ ] 2.3.1
#   [ ] 2.3.1.1 p.23

# reduce
ret = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].reduce do |x, y|
  x + y
end
p ret

# expression
class Number < Struct.new(:value)
end

class Add < Struct.new(:left, :right)
end

class Multiply < Struct.new(:left, :right)
end

pp Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4))
)
