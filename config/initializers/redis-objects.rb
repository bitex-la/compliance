# frozen_string_literal: true

Redis::Objects.redis = ConnectionPool.new(size: Settings.redis.pool_size) do
  Redis::Store::Factory.create(Settings.redis.cache_url, serializer: nil)
end
