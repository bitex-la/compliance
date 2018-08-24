module ArbreHelpers
  def self.fruit_show_page(context)
    context.instance_eval do
      columns do
        column span: 2 do
          ArbreHelpers.fruit_attribute_table(self, resource)
          if attachments = resource.attachments.presence
            h3 "Attachments"
            ArbreHelpers.attachments_list(self, attachments)
          end
        end

        column do 
          ArbreHelpers.fruit_relations_panels(self, resource)
        end 
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

  def self.fields_for_replaces(context, form, assoc)
    context.instance_eval do
      if replaceable = context.resource.person.send(assoc).current.presence
        form.input :replaces, collection: replaceable
        form.input :copy_attachments,
          label: "Move attachments of replaced #{assoc} to the new one"
      end
    end
  end

  def self.attachment_preview(context, a, show_attached_to = false)
    return if a.nil? || a.new_record?
    context.instance_eval do
      if IMAGEABLE_CONTENT_TYPES.include?(a.document_content_type) 
        div do
          link_to image_tag(a.document.url, width: '100%'), a.document.url, target: "_blank"
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

  def self.panel_grid(context, objects, &block)
    context.instance_eval do
      objects.in_groups_of(2).each do |group|
        columns do
          group.each_with_index do |a, i|
            column do
              next if a.nil?
              panel a.name do
                instance_exec a, &block
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
    ArbreHelpers.has_many_form context, form, :attachments do |af, ctx|
      a = af.object
      if a.persisted?
        af.input :_destroy, as: :boolean, required: false, label: 'Remove', class: "check_box_remove"
        af.template.concat(
          Arbre::Context.new({}, af.template){
            ArbreHelpers.attachment_preview(self, a)
          }.to_s
        )
      else
        af.input :document, as: :file, label: "Attachment"
      end
    end
  end

  def self.fruit_collection_show_tab(context, title, relation)
    context.instance_eval do
      all = resource.send(relation).current.order("created_at DESC")
      tab "#{title} (#{all.count})" do
        ArbreHelpers.panel_grid(self, all) do |d|
          ArbreHelpers.fruit_show_section(self, d)
        end
      end
    end
  end

  def self.fruit_show_section(context, fruit)
    context.instance_eval do
      columns = fruit.class.columns.map{|c| c.name.gsub(/_id$/,'') } -
        %w(id person issue created_at updated_at replaces)
      attributes_table_for fruit do
        row(:show){|o| link_to o.name, o }
        columns.each do |n|
          row(n)
        end
        if fruit.replaces
          row(:replaces)
        end
        row(:created_at)
        row(:issue)
      end
      fruit.attachments.each do |a|
        ArbreHelpers.attachment_preview(self, a)
      end
    end
  end

  def self.seed_collection_show_tab(context, title, relation)
    context.instance_eval do
      tab "#{title} (#{resource.send(relation).count})" do
        ArbreHelpers.panel_grid(self, resource.send(relation)) do |d|
          ArbreHelpers.seed_show_section(self, d)
        end
      end
    end
  end

  def self.seed_show_section(context, seed, others = [])
    context.instance_eval do
      ArbreHelpers.seed_attributes_table self, seed, others
      attachments = seed.fruit ? seed.fruit.attachments : seed.attachments
      attachments.each do |a|
        ArbreHelpers.attachment_preview(self, a)
      end
    end
  end

  def self.seed_attributes_table(context, resource, others = [])
    columns = resource.class.columns.map(&:name) - others.map(&:to_s)
    columns = columns.map{|c| c.gsub(/_id$/,'') } -
      %w(id issue fruit created_at updated_at replaces copy_attachments)
    
    context.instance_eval do
      attributes_table_for resource, :fruit, *columns, *others
    end
  end

  def self.attachments_list(context, attachments)
    return if attachments.blank?
    context.instance_eval do
      attachments.each do |a|
        ArbreHelpers.attachment_preview(self, a)
      end
    end
  end
end
