module Parametrizable
  extend ActiveSupport::Concern

  included do
    def to_underscore(attribute)
      return if send(attribute).nil?
      send("#{attribute}=", 
        send(attribute).parameterize(separator: '_'))
    end
  end
end