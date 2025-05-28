# frozen_string_literal: true

class RegMachineCoder
   def is_prime?(num)
      return false if num <= 1
      return true if num == 2
      return false if num.even?

      sqrt_num = Math.sqrt(num).to_i
      (3..sqrt_num).step(2) do |i|
         return false if num % i == 0
      end
      true
   end

   def count_next_prime(n)
      current = n + 1
      current += 1 if current.even? && current != 2

      loop do
         return current if is_prime?(current)
         current += 2
      end
   end

   def get_instructions_to_array(file_path)
      raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)

      File.readlines(file_path).each_with_index.map do |line, idx|
         begin
            instructions = line.strip.split(',').map(&:to_i)
            instructions unless instructions.empty?
         rescue => e
            puts "Error parsing line #{idx + 1}: #{e.message}"
            nil
         end
      end.compact
   end

   # gets the filename of file containing lines with registry machine commands
   # @return code of the machine
   def code(file_path)
      instructions = get_instructions_to_array(file_path)
      result = 1
      z = []
      instructions.each do |line|
         prime = 1
         zi = 1
         line.each do |num|
            prime = count_next_prime(prime)
            zi *= prime ** (num + 1)
         end
         z.append(zi)
      end
      # prime = 1
      # z.each do |zi|
      #    prime = count_next_prime(prime)
      #    result *= prime ** (zi + 1)
      z
   end

   # gets code of registry machine and return string of human-readable instructions
   def decode(num)
      z = []
      prime = 1

      while num > 1 do
         zi = 0
         prime = count_next_prime(prime)
         while num % prime == 0 do
            ++zi
            num /= prime
         end
         z.append(zi)
      end
      z
   end
end

