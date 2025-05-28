$x = Array.new(2,0)
      def l1()
        $x[0] = 42
        l2
      end
      
      def l2()
        if $x[1]== 0
        l3
        else l2
        end
      end
      
      def l3()
        puts $x[0]
        exit
      end
      puts l1