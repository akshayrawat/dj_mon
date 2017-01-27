module DjMon
  module AuthStrategy
    class None
      def process controller
        true
      end
    end
  end
end
