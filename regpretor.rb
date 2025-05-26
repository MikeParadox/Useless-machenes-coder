# frozen_string_literal: true

class Regpretor
  def interpret(filepath)
    lines = File.readlines(filepath)

    rb = File.open("regmach.rb", "w")
    max_reg = countRegs(lines)
    rb.write("$x = Array.new(#{max_reg},0)")
    lines.each do |line|

      conv = convert(line)
      rb.write(conv)
    end


    rb.write("puts l1")
    rb.close
    output = `ruby regmach.rb`
    puts "Output from regmach.rb:\n#{output}"
  end

  def countRegs(lines)
    lines.map do |line|
      split = line.split(",")
      split[2].to_i if split.size >= 3
    end.compact.max
  end

  def convert(line)
    codes = line.split(',').map {|code| code.to_i}
    #codes = line_split.each do |code| code.to_i end
    case codes[0]
      when 1 then return %{
      def l#{codes[1]}()
        $x[#{codes[2]-1}] = #{codes[3]}
        l#{codes[1]+1}
      end
      }
      when 2 then return %{
      def l#{codes[1]}()
        $x[#{codes[2]-1}] += 1
        l#{codes[1]+1}
      end
      }
     when 3 then puts %{
      def l#{codes[1]}()
        $x[#{codes[2]-1}] -= 1
        l#{codes[1]+1}
      end
      }
     when 4 then return %{
      def l#{codes[1]}()
        if $x[#{codes[2]-1}]== 0
        l#{codes[3]}
        else l#{codes[4]}
        end
      end
      }
      when 5 then return %{
      def l#{codes[1]}()
        puts $x[0]
        exit
      end
      }
    end

  end
end

Regpretor.new.interpret("test.txt")
