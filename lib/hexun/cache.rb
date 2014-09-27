module Hexun
  class Cache
    def self.get_or_set(key, &callback)
      if Cache.has? key
        puts "Cache hit: #{key}"

        return Cache.get(key)
      else
        puts "Cache miss: #{key}"

        value = yield
        Cache.set(key, value)
        return value
      end
    end

    def self.set(key, value)
      begin
        dump = Marshal.dump(value)
      rescue Exception => e
        puts "Save to cache failed, abort."
        return false
      end

      File.open("tmp/#{key}", 'wb') {|f| f.write(dump) }
    end

    def self.get(key)
      Marshal.load(File.open("tmp/#{key}", 'rb'))
    end

    def self.has?(key)
      File.exist?("tmp/#{key}")
    end
  end
end