module ArbreHelpers

  def self.issues_panel(context, issues, title)
    context.instance_eval do
      panel title do
        table_for issues do |i|
          i.column("ID") { |issue|
            link_to(issue.id, issue_path(issue)) 
          }
          i.column("Person") { |issue|
            link_to(issue.person.id, person_path(issue.person)) 
          }
          i.column("Created at") { |issue|
            issue.created_at 
          }
          i.column("Updated at") { |issue|
            issue.updated_at 
          }
          i.column("Actions") { |issue|
            span link_to("View", issue_path(issue))
          }
        end
      end
    end
  end

  def self.attachments_panel(context, attachments)
    context.instance_eval do
      next if attachments.empty?

      panel 'Attachments' do
        table_for attachments do |a|
          a.column("ID") do |attachment|
            link_to(attachment.id, attachment_path(attachment))
          end
          a.column("File Name")    { |attachment| attachment.document_file_name }
          a.column("Content Type") { |attachment| attachment.document_content_type }
          a.column("File Size")    { |attachment| attachment.document_file_size }
          a.column("") do |attachment|
            link_to "View file", attachment.document.url, target: '_blank'
          end
          a.column("") do |attachment|
            link_to("View detail", attachment_path(attachment))
          end
          a.column("") do |attachment|
            link_to("Edit", edit_attachment_path(attachment))
          end
        end
      end
    end
  end

  def self.has_one_form(context, builder, title, relationship, &fields)
    b_object =  builder.object.send(relationship) || builder.object.send("build_#{relationship}")
    builder.inputs(title, for: [relationship, b_object], id: relationship.to_s, &fields)
    if b_object.persisted?
      context.link_to(
        "Show", 
        b_object, 
        target: '_blank')

      unless b_object.class.name == 'Attachment'
        context.link_to("Remove Seed", 
          b_object, 
          method: :delete, 
          data: {confirm: "Are you sure?"})
      end
    end
  end

  def self.has_many_form(context, builder, relationship, &fields)
    builder.has_many relationship do |f|
      instance_exec(f, context, &fields)
      if f.object.persisted?
        f.template.concat(context.link_to(
          "Show", 
          f.object, 
          target: '_blank'
        ))

        unless f.object.class.name == 'Attachment'
          f.template.concat(context.link_to("Remove Seed", 
            f.object, 
            method: :delete, 
            data: {confirm: "Are you sure?"}
          ))
        end 
      end
    end
  end

  def self.has_many_attachments(context, form)
    ArbreHelpers.has_many_form context, form, :attachments do |af|
      document = af.object.document
      hint = if document.nil?
        context.content_tag(:span, "No File Yet")
      else
        context.link_to('Click to enlarge', af.object.document.url, target: '_blank')
      end

      af.input :document, as: :file, hint: hint,
        label: "File #{af.object.document_file_name}"

      af.input :_destroy, as: :boolean, required: false, label: 'Remove image'
    end
  end
end
