module ArbreHelpers
  class Replacement
    def self.fields_for_replaces(context, form, assoc)
      context.instance_eval do
        if replaceable = context.resource.person.send(assoc).current.presence
          form.input :replaces, collection: replaceable
          form.input :copy_attachments,
            label: "Move attachments of replaced #{assoc} to the new one"
        end
      end
    end
  end
end
