module ArbreHelpers
  class Affinity
    def self.affinity_card(context, affinity)
      context.instance_eval do
        source = self.resource.try(:person) || self.resource
        from = source
        to = affinity.related_one(source)
        affinity_kind_label = affinity.get_label(source)

        row(:person) do
          link_to from.name, from 
        end
        row(:related_person) do
          link_to to.name, to
        end

        row(:affinity_kind) do
          affinity.get_label(self.resource)
        end
        row(:created_at)
        row(:issue)
      end
    end
  end
end