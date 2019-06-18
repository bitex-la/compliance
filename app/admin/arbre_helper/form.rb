module ArbreHelpers
  class Form
    def self.has_one_form(context, builder, title, relationship, &fields)
      Appsignal.instrument("render_#{relationship.to_s}") do
        b_object =  builder.object.send(relationship) || builder.object.send("build_#{relationship}")
        builder.inputs(title, for: [relationship, b_object], id: relationship.to_s, &fields)
      end
    end

    def self.has_many_form(context, builder, relationship, extra={}, &fields)
      Appsignal.instrument("render_#{relationship.to_s}") do
        builder.has_many relationship, class: "#{'can_remove' unless extra[:cant_remove]}" do |f|
          Appsignal.instrument("render_one_of_#{relationship.to_s}") do
            instance_exec(f, context, &fields)
            if f.object
              if f.object.persisted? && !extra[:cant_remove]
                unless f.object.class.name == 'Attachment' || f.object.class.name == 'Task'
                  f.template.concat(context.link_to("Remove",
                    f.object,
                    method: :delete,
                    data: {confirm: "This seed has been saved, removing it will delete all the seed data. Are you sure?"},
                    class: 'button has_many_remove'
                  ))
                end
              end
            end
          end
        end
      end
    end
  end
end