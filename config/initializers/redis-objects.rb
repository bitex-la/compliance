# frozen_string_literal: true

Redis::Objects.redis = ConnectionPool.new(size: Settings.redis.pool_size) do
  Redis::Store::Factory.create(Settings.redis.cache_url, serializer: nil)
end

require 'redis/base_object'

# Redis::Store::Namespace adds a namespace only to a subset of redis commands
# used in some Stores defined by Rails so we need to compute a namespaced key ourselves.
class Redis::BaseObject
  module Namespace
    def key
      redis.interpolate(super)
    end
  end

  prepend Namespace
end
