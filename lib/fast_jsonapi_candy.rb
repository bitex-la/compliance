module FastJsonapiCandy
  module PersonThing
    extend ActiveSupport::Concern

    included do
      @naming = Garden::Naming.new(name)
      include Serializer
      build_belongs_to :person
      has_one :seed, record_type: @naming.seed_plural
      build_has_many :attachments
    end

    class_methods do
      def derive_seed_serializer! 
        Object.const_set @naming.seed_serializer, Class.new do
          include FastJsonapiCandy::PersonThingSeed
        end
      end
    end
  end

  module PersonThingSeed
    extend ActiveSupport::Concern

    included do
      naming = Garden::Naming.new(name)
      include Serializer
      build_belongs_to :issue
      belongs_to :fruit, record_type: naming.plural
      build_has_many :attachments
      attributes *naming.serializer.constantize.attributes_to_serialize.keys
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      include FastJsonapi::ObjectSerializer
      set_type Garden::Naming.new(name).plural
    end

    class_methods do
      def build_belongs_to(*them)
        them.each do |it|
          belongs_to it, record_type: it.to_s.pluralize
        end
      end

      def build_has_many(*them)
        them.each do |it|
          has_many it, record_type: it
        end
      end

      def build_has_one(*them)
        them.each do |it|
          has_one it, record_type: it.to_s.pluralize
        end
      end
    end
  end
end
