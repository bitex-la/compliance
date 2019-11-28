# frozen_string_literal: true

Redis::Objects.redis = ConnectionPool.new(size: Settings.redis.pool_size) do
  Redis::Store::Factory.create(
    url: Settings.redis.cache_url,
    namespace: Settings.redis.namespace,
    serializer: nil
  )
end
