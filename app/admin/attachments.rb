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

  menu false

  action_item :fix, only: :show, if: lambda { resource.attached_to_fruit.nil? && resource.attached_to_seed.nil? } do
    link_to 'Attach to fruit', attach_attachment_path(resource), method: :get
  end

  member_action :attach, method: :get do 
    render 'attachments/attach.html.haml', 
      locals: {person: resource.person, attachment: resource}
  end

  member_action :attach_to_fruit, method: :post do
    resource.attached_to_fruit = resource.person.fruits.find{ |x| x.id == params[:fruit].to_i }
    resource.save
    flash[:notice] = 'Attachment updated successfully!'
    redirect_to attachment_path(resource) 
  end

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
      row :issue do
        if issue = attachment.attached_to_seed.try(:issue)
          link_to "Issue #{issue.id}", edit_person_issue_path(issue.person, issue)
        end
      end
      row :person do
        if person = attachment.attached_to_fruit.try(:person)
          link_to "Person #{person.id}", person_path(person)
        end
      end
      row :attached_to_seed
      row :attached_to_fruit
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
