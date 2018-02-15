ActiveAdmin.register Attachment do

  IMAGEABLE_CONTENT_TYPES ||= [
    'image/jpeg', 
    'image/jpg',
    'image/gif', 
    'image/png',
  ]

  DOWNLOADABLE_CONTENT_TYPES ||= [
    'application/pdf',
    'application/zip',
    'application/x-rar-compressed'
  ]

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  begin
    permit_params :id, :document, :person_id

    form do |f|
      f.inputs "Upload" do
        f.input :person
        f.input :document, required: true, as: :file
      end
      f.actions
    end
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :seed_to
      row :document_file_name
      row :document_content_type
      row :document_file_size
      if IMAGEABLE_CONTENT_TYPES.include?(attachment.document_content_type)
        row "Preview (click to enlarge)" do
          link_to image_tag(attachment.document.url), attachment.document.url, target: "_blank"
        end
      elsif DOWNLOADABLE_CONTENT_TYPES.include?(attachment.document_content_type)
        row "Preview (click to download)" do
          link_to 'Download file', attachment.document.url, target: "_blank"
        end 
      end
    end
  end
end
