require 'pry'

require 'queued_state_machine'

class Test
  include QueuedStateMachine
  
  state :a, initial: true
  state :b
  state :c
  
  transition(from: :a, to: [:b, :c])
  transition(to: :a)
  
  on_transition(from: :a, to: [:b, :c]) do
    puts "from: a to: b,c"
  end
  
  on_transition(from: :b, to: :c) do
    puts "from: b to: c"
  end
  
  on_transition(from: [:a,:c], to: :b) do
    puts "from: a,c to: b"
  end
  
  on_transition(to: :a) do
    puts "from: * to: a"
    puts "start"
    to(:c)
    puts "end"
  end
  
  def initialize
    puts "initialize"
    super
  end
  
end

t = Test.new
t.state
t.at?(:a)
t.to(:b)
puts
t.to(:a)
puts t.state
t.to(:b) # should fail
binding.pry
