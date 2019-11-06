# frozen_string_literal: true

Redis::Objects.redis = ConnectionPool.new(size: Settings.redis.pool_size) do
  Redis.new(url: Settings.redis.cache_url)
end
