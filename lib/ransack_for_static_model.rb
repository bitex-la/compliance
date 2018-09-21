module RansackForStaticModel
  extend ActiveSupport::Concern
  class_methods do
    def ransackable_static_belongs_to(association, opts = {})
      module_name = self.to_s.split("::")[0..-2].join("::")
      association_class = [ opts[:class_name],
          "#{module_name}::#{association.to_s.camelize}",
          association.to_s.camelize,
        ].compact.collect(&:safe_constantize).compact.first

      if association_class.include?(ActiveModel::Model)
        raise "Cannot use ransackable_static_belongs_to on model"
      end

      belongs_to(association, opts)

  	  validates association, inclusion: { in: association_class.all } 
      ransacker("#{association}_code",
        formatter: proc { |v| association_class.find_by_code(v).try(:id) }
      ) do |parent|
        parent.table["#{association}_id"]
      end
    end
 end
end
