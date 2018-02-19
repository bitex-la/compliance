module ArbreHelpers
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
    builder.inputs(title, for: [relationship, b_object], &fields)
    if b_object.persisted?
      context.span context.link_to("Show", b_object)
    end
  end

  def self.has_many_form(context, builder, relationship, &fields)
    builder.has_many relationship do |f|
      instance_exec(f, context, &fields)
      if f.object.persisted?
        f.template.concat(context.link_to "Show", f.object)
      end 
    end
  end
end
