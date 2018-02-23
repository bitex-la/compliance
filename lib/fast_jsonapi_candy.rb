module FastJsonapiCandy
  module PersonThing
    extend ActiveSupport::Concern

    included do
      include Serializer
      build_belongs_to :person
      build_has_one "#{name.underscore[0..-12]}_seed"
      build_has_many :attachments
    end

    class_methods do
      def derive_seed_serializer! 
        Object.const_set "#{name[0..-11]}SeedSerializer", Class.new do
          include FastJsonapiCandy::PersonThingSeed
        end
      end
    end
  end

  module PersonThingSeed
    extend ActiveSupport::Concern

    included do
      include Serializer
      build_belongs_to :issue, name.underscore[0..-17].to_sym
      build_has_many :attachments
      attributes *"#{name[0..-15]}Serializer".constantize.attributes_to_serialize.keys
    end
  end

  module Serializer
    extend ActiveSupport::Concern

    included do
      include FastJsonapi::ObjectSerializer
      set_type name[0..-11].pluralize.underscore
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
