$x = Array.new(3,0)
      def l1()
        $x[0] = 42
        l2
      end
      
      def l2()
        $x[2] += 1
        l3
      end
      
      def l3()
        if $x[1]== 0
        l3
        else l2
        end
      end
      
      def l4()
        puts $x[0]
        exit
      end
      $x[1] = 0
puts l1
