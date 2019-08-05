ActiveAdmin.register Attachment do
  menu priority: 6

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

  permit_params :id, :document, :person_id,
    :attached_to_seed_gid, :attached_to_fruit_gid

  form do |f|
    if f.object.new_record?
      f.inputs "Upload" do
        f.input :person
        f.input :document, required: true, as: :file
      end
    end

    f.inputs "Attached to" do
      if seed = f.object.attached_to_seed
        f.input :attached_to_seed_gid, as: :select,
          collection: seed.issue.all_seeds.map{|o| [o.name, o.to_global_id.to_s] }
      else
        f.input :attached_to_fruit_gid, as: :select,
          collection: f.object.person.fruits.map{|o| [o.name, o.to_global_id.to_s] }
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :issue
      row :person
      row :attached_to_seed
      row :attached_to_fruit
      row :document_file_name
      row :document_content_type
      row :document_file_size
      if IMAGEABLE_CONTENT_TYPES.include?(attachment.document_content_type)
        row "Preview (click to enlarge)" do
          link_to image_tag(attachment.document_url), attachment.document.url, target: "_blank"
        end
      elsif DOWNLOADABLE_CONTENT_TYPES.include?(attachment.document_content_type)
        row "Preview (click to download)" do
          link_to 'Download file', attachment.document_url, target: "_blank"
        end 
      end
    end
  end
end
