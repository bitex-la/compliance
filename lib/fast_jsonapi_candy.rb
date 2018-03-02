module FastJsonapiCandy
  module Fruit
    extend ActiveSupport::Concern

    included do
      @naming = Garden::Naming.new(name)
      include Serializer
      set_type @naming.plural
      build_belongs_to :person
      has_one :seed, record_type: @naming.seed_plural
      build_has_many :attachments
    end

    class_methods do
      def derive_seed_serializer!
        klass = Class.new
        Object.const_set(@naming.seed_serializer, klass)
        klass.class_eval{ include FastJsonapiCandy::Seed }  
      end
    end
  end

  module Seed
    extend ActiveSupport::Concern

    included do
      naming = Garden::Naming.new(name)
      include Serializer
      set_type naming.seed_plural
      build_belongs_to :issue
      belongs_to :fruit,
        record_type: naming.plural,
        id_method_name: "#{naming.fruit.underscore}_id"
      build_has_many :attachments

      if attrs = naming.serializer.constantize.attributes_to_serialize
        attributes *attrs.try(:keys)
      else
        raise "Cannot derive #{name} as seed has no attributes."
      end
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      include FastJsonapi::ObjectSerializer
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
