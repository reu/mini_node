module MiniNode
  module HTTP
    class Request
      attr_accessor :verb
      attr_accessor :path
      attr_accessor :headers
      attr_accessor :body

      %w(get post put patch delete head options).each do |verb|
        define_method(verb + "?") do
          self.verb.to_s.downcase == verb
        end
      end

      def keep_alive?
        headers["Connection"].to_s.downcase == "keep-alive"
      end
    end
  end
end
