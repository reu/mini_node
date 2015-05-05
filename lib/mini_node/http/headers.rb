module MiniNode
  module HTTP
    class Headers < Hash
      def [](key)
        super normalize(key)
      end

      def []=(key, value)
        super normalize(key), value
      end

      def fetch(key, *args, &block)
        super normalize(key), *args, &block
      end

      def self.from_hash(hash)
        headers = new
        headers.update(hash)
        headers
      end

      private

      def normalize(key)
        key.downcase
      end
    end
  end
end
