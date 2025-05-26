class TuringMachine
  attr_accessor :left, :right, :state, :transitions

  def initialize(tape, transitions)
    @left = []
    @right = tape.chars
    @state = 'q1'
    @transitions = transitions
  end

  def current_symbol
    right[0] || '_'
  end

  def write(symbol)
    right[0] = symbol
  end

  def move_head(direction)
    if direction == 'R'
      left.push(right.shift || '_')
    else
      right.unshift(left.pop || '_')
    end
  end

  def step
    action = transitions.dig(state, current_symbol)
    if action
      write_symbol, direction, next_state = action
      write(write_symbol)
      move_head(direction)
      self.state = next_state
    else
      self.state = nil
    end
  end

  def run(max_steps = 1000)
    steps = 0
    while state != "q0" && !state.nil? && steps < max_steps
      step
      steps += 1
    end

    if steps >= max_steps
      puts "Превышено число шагов"
    end
  end

  def visualize_tape
    full_tape = left.reverse + right
    first = full_tape.index { |c| c != '_' } || 0
    last = full_tape.rindex { |c| c != '_' } || 0
    trimmed = full_tape[first..last]
    head_pos = left.size - first
    head_line = ' ' * head_pos + '^'
    puts "Лента: #{trimmed.join}"
    puts "       #{head_line}"
  end
end

def load_machine(filename)
  transitions = Hash.new { |h, k| h[k] = {} }
  tape = ""

  File.readlines(filename).each do |line|
    line.strip!
    next if line.empty? || line.start_with?('#')

    if line =~ /^(\w+)\s+(\S)\s*->\s*\((\S),([RL]),(\w+)\)$/
      state, read, write, dir, next_state = $1, $2, $3, $4, $5
      transitions[state][read] = [write, dir, next_state]
    elsif line =~ /^tape:\s*([01A-B_]+)$/
      tape = $1
    end
  end

  [tape, transitions]
end

tape, transitions = load_machine("machine.txt")

machine = TuringMachine.new(tape, transitions)
machine.run(100)
machine.visualize_tape