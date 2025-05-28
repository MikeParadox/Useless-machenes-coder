# frozen_string_literal: true

class Regpretor
  def convert_code_to_instuctions(filepath)
    result = []
    File.readlines(filepath).map do |line|
      values = line.chomp.split(',')
      result << values
    end
    newline = RUBY_PLATFORM =~ /win32|win64|mswin|mingw/ ? "\r\n" : "\n"
    reg_machine = ""
    result.each_entry do |line|
      command = ""
      if line.length == 2
        command += line[1] + ": stop"
      else
        if line.length < 5
          command += line[1].strip + ": x" + line[2].strip
          command = command.strip
          if line[0] == "1"
            command += "<-" + line[3].strip
          elsif line[0] == "2"
            command += "<-x" + line[2].strip + "+1"
          elsif line[0] == "3"
            command += "x<-" + line[2].strip + "-1"
          end
        else
          command += line[1] + ": if x" + line[2] + "=0 goto " +
                     line[3] + " else " + line[4]
        end
      end
      reg_machine += command + newline
    end

    puts reg_machine
    File.open("machine_code.txt", 'w') do |file|
      reg_machine.each_line { |line| file.puts(line.chomp) }

    end
  end


  def run(filepath,*regs)
    rb = File.open(filepath, "a") do |file|
      regs.each_with_index do |reg,i|
        puts reg
        file.puts "$x[#{i+1}] = #{regs[i].first}"
      end
      file.puts "puts l1"
    end
    output = `ruby #{filepath}`
    puts "Output from #{filepath}:\n#{output}"
  end

  def interpret(filepath)
    lines = File.readlines(filepath)
    name = File.basename(filepath, ".*")
    rb = File.open("#{name}.rb", "w")
    max_reg = countRegs(lines)
    rb.write("$x = Array.new(#{max_reg},0)")
    lines.each do |line|

      conv = convert(line)
      rb.write(conv)
    end

    rb.write("puts l1")
    rb.close
    File.basename(rb)
  end

  def countRegs(lines)
    lines.map do |line|
      split = line.split(",")
      split[2].to_i if split.size >= 3
    end.compact.max
  end

  def convert(line)
    codes = line.split(',').map { |code| code.to_i }
    # codes = line_split.each do |code| code.to_i end
    case codes[0]
    when 1 then return %{
      def l#{codes[1]}()
        $x[#{codes[2] - 1}] = #{codes[3]}
        l#{codes[1] + 1}
      end
      }
    when 2 then return %{
      def l#{codes[1]}()
        $x[#{codes[2] - 1}] += 1
        l#{codes[1] + 1}
      end
      }
    when 3 then puts %{
      def l#{codes[1]}()
        $x[#{codes[2] - 1}] -= 1
        l#{codes[1] + 1}
      end
      }
    when 4 then return %{
      def l#{codes[1]}()
        if $x[#{codes[2] - 1}]== 0
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

Regpretor.new.convert_code_to_instuctions("test.txt")
Regpretor.new.interpret("test.txt")
Regpretor.new.run("test.rb",[0])
