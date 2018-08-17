module ArbreHelpers
  def self.fruit_show_page(context)
    context.instance_eval do
      columns do
        column span: 2 do
          ArbreHelpers.fruit_attribute_table(self, resource)
          if attachments = resource.attachments.presence
            h3 "Attachments"
            ArbreHelpers.attachments_grid(self, attachments)
          end
        end

        column do 
          ArbreHelpers.fruit_relations_panels(self, resource)
        end 
      end  
    end
  end

  def self.fields_for_replaces(context, form, assoc)
    context.instance_eval do
      if replaceable = context.resource.person.send(assoc).current.presence
        form.input :replaces, collection: replaceable
        form.input :copy_attachments,
          label: "Move attachments of replaced #{assoc} to the new one"
      end
    end
  end

  def self.fruit_attribute_table(context, resource, &block)
    context.instance_eval do 
      if block
        attributes_table_for(resource, &block)
      else
        blacklist = %i(id person issue_id created_at updated_at replaced_by)
        attributes_table_for(resource, *(default_attribute_table_rows - blacklist))
      end
    end
  end

  def self.fruit_relations_panels(context, resource)
    context.instance_eval do
      person = resource.person

      attributes_table_for(resource) do
        row :id
        if resource.replaced_by
          row :replaced_by
        end
        row :person
        row :issue
        row :created_at
      end

      if previous = resource.previous_versions.presence
        h3 "Previous versions"
        previous.each do |r|
          span r.created_at.strftime("%e %b %Y :")
          span link_to "#{r.name}", r
          br
        end
      end

      if others = resource.others_for_person.presence
        h3 "Other #{resource.class.name.pluralize.titleize} for person"
        others.each do |r|
          span r.created_at.strftime("%e %b %Y :")
          span link_to "#{r.name}", r
          br
        end
      end
    end
  end

  def self.issues_panel(context, issues, title)
    context.instance_eval do
      panel title, class: title.gsub(' ','').underscore do
        table_for issues do |i|
          i.column("ID") { |issue|
            link_to(issue.id, person_issue_path(issue.person, issue))
          }
          i.column("Person") { |issue|
            link_to(issue.person.id, person_path(issue.person))
          }
          i.column("Email") { |issue|
            if issue.person.emails.any?
              link_to(issue.person.emails.first.address, person_path(issue.person))
            elsif issue.email_seeds.any?
              link_to(issue.email_seeds.first.address, person_path(issue.person))
            end
          }
          i.column("Seeds") { |issue|
            issue.modifications_count
          }
          i.column("Observations") { |issue|
            issue.observations.count
          }
          i.column("Created at") { |issue|
            issue.created_at
          }
          i.column("Updated at") { |issue|
            issue.updated_at
          }
          i.column("Actions") { |issue|
            span link_to("View", person_issue_path(issue.person, issue))
          }
        end
      end
    end
  end

  def self.attachments_grid(context, attachments, show_attached_to = false)
    context.instance_eval do
      attachments.in_groups_of(2).each do |group|
        columns do
          group.each_with_index do |a, i|
            column do
              next if a.nil? || a.new_record?
              if IMAGEABLE_CONTENT_TYPES.include?(a.document_content_type) 
                div do
                  link_to image_tag(a.document.url, width: '100%'), a.document.url
                end
                attributes_table_for a do
                  row(:attachment){|o| link_to o.name, o }
                  if show_attached_to
                    row(:attached_to_type)
                    row(:attached_to)
                  end
                end
              else
                div do
                  link_to "Download (no preview available)", a.document.url,
                    target: "_blank", class: 'button button-block'
                end
                attributes_table_for a do
                  row(:type){|o| o.document_content_type }
                  row(:size){|o| number_to_human_size o.document_file_size }
                  row(:attachment){|o| link_to o.name, attachment_path(o) }
                  if show_attached_to
                    row(:attached_to_type)
                    row(:attached_to)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def self.attachments_panel(context, attachments)
    context.instance_eval do
      panel "Attachments" do
        if attachments.any?
          table_for attachments.each do |a|
            a.column do |attachment|
              context.div(h4 "#{attachment.document_file_name} - #{attachment.document_content_type}")
              context.div(span "#{attachment.attached_to_fruit.class.name}")
              context.div(link_to 'View', attachment_path(attachment))
            end
          end
        else 
          span "0 attachments"
        end
      end
    end
  end

  def self.orphan_attachments(context, builder)
    context.instance_eval do
      if builder.present? && 
          builder.attachments.where(attached_to_seed: nil).any? &&
          builder.attachments.where(attached_to_fruit: nil).any?
        context.instance_eval do
          panel "Orphan Attachments" do
            table_for builder.attachments
              .where("attached_to_seed_id is ? AND attached_to_fruit_id is ?", nil, nil)
              .each do |a|
                a.column do |attachment|
                  h3 "#{attachment.document_file_name} - #{attachment.document_content_type}"
                  if IMAGEABLE_CONTENT_TYPES.include?(attachment.document_content_type)
                    context.div(image_tag(attachment.document.url, width: '100%'))
                    context.div(link_to 'View', attachment_path(attachment))
                  elsif DOWNLOADABLE_CONTENT_TYPES.include?(attachment.document_content_type)
                    link_to 'Download file', attachment.document.url, target: "_blank"
                  end
                end
            end
          end
        end
      end
    end
  end

  def self.has_one_form(context, builder, title, relationship, &fields)
    b_object =  builder.object.send(relationship) || builder.object.send("build_#{relationship}")
    builder.inputs(title, for: [relationship, b_object], id: relationship.to_s, &fields)
    if b_object.persisted?
      context.span(context.link_to(
        "Show",
        b_object,
        target: '_blank'))

      unless b_object.class == Attachment
        context.span(context.link_to("Remove Entity",
          b_object,
          method: :delete,
          data: {confirm: "Are you sure?"}))
      end
    end
  end

  def self.has_many_form(context, builder, relationship, extra={}, &fields)
    builder.has_many relationship, class: "#{'can_remove' unless extra[:cant_remove]}" do |f|
      instance_exec(f, context, &fields)
      if f.object.persisted? && !extra[:cant_remove]
        unless f.object.class.name == 'Attachment'
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

  def self.has_many_attachments(context, form)
    ArbreHelpers.has_many_form context, form, :attachments do |af|
      a = af.object
      if a.persisted?
        af.template.concat("<label class='label'>Attachment</label>".html_safe)
        af.template.concat(context.link_to(a.name, a, target: '_blank'))
        af.input :_destroy, as: :boolean, required: false, label: 'Remove', class: "check_box_remove"
      else
        af.input :document, as: :file, label: "Attachment"
      end
    end
  end
end
