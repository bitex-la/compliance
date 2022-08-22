module ArbreHelpers
  class Attachment
    def self.preview(context, a, show_attached_to = false)
      return if a.nil? || a.new_record?
      context.instance_eval do
        if IMAGEABLE_CONTENT_TYPES.include?(a.document_content_type) 
          div do
            link_to image_tag(a.document_url, width: '100%'), a.document_url, target: "_blank"
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
            link_to "Download (no preview available)", a.document_url,
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

    def self.has_many_attachments(context, form)
      ArbreHelpers::Form.has_many_form context, form, :attachments, new_button_enabled: false do |af, ctx|
        a = af.object
        if a.persisted?
          af.input :_destroy, as: :boolean, required: false, label: 'Remove', class: "check_box_remove"
          af.template.concat(
            Arbre::Context.new({}, af.template){
              ArbreHelpers::Attachment.preview(self, a)
            }.to_s
          )
        else
          af.input :document, as: :file, label: "Attachment"
        end
      end
      form.input :multiple_documents, as: :file, label: "Add Attachments", input_html: { multiple: true }, hint: "Max. size per file 10MB"
    end

    def self.attachments_list(context, attachments)
      return if attachments.blank?
      context.instance_eval do
        attachments.each do |a|
          ArbreHelpers::Attachment.preview(self, a)
        end
      end
    end
  end
end
