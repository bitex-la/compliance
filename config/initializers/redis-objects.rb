Redis::Objects.redis = ConnectionPool.new(size: Settings.redis.pool_size) do
  Redis.new(url: Settings.redis.cache_url)
end

module Redis::Objects::JsonMarshalling
  def key
    redis.interpolate(super)
  end

  def marshal(value, domarshal=false)
    if options[:marshal] || domarshal
      # mode: :compat will attempt to serialize value with #as_json, #to_json, #to_hash
      # or default to mode: :object if none of those methods are present
      Oj.dump(value, mode: :compat)
    else
      value
    end
  end

  def unmarshal(value, domarshal=false)
    if value.nil?
      nil
    elsif options[:marshal] || domarshal
      if value.is_a?(Array)
        value.map{|v| unmarshal(v, domarshal)}
      elsif !value.is_a?(String)
        value
      else
        # mode: :object can deserialize anything that was encoded with mode: :compat
        Oj.load(value, mode: :object, bigdecimal_load: true, symbol_keys: true)
      end
    else
      value
    end
  end
end

class RedisSortedSet < Redis::SortedSet
  include Redis::Objects::JsonMarshalling
end

class RedisHashKey < Redis::HashKey
  include Redis::Objects::JsonMarshalling
end

class RedisList < Redis::List
  include Redis::Objects::JsonMarshalling
end
