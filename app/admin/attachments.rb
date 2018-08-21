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

  scope :fruit_orphan, default: true
  scope :all

  index do
    column(:id)
    column(:person)
    column(:document_file_name)
    column(:document_content_type)
    column(:document_file_size)
    column("") do |attachment|
      link_to "View file", attachment.document.url, target: '_blank'
    end
    column("") do |attachment|
      link_to("View detail", attachment_path(attachment))
    end
    column("") do |attachment|
      if attachment.fruit_orphan?
        link_to("Attach to fruit", attach_attachment_path(attachment))
      end
    end
  end

  action_item :fix, only: :show, if: lambda { resource.fruit_orphan? } do
    link_to 'Attach to fruit', attach_attachment_path(resource), method: :get
  end

  member_action :attach, method: :get do 
    render 'attachments/attach.html.haml', 
      locals: {person: resource.person, attachment: resource}
  end

  member_action :attach_to_fruit, method: :post do
    fruit_class = params[:fruit].split(',')[0]
    fruit_id = params[:fruit].split(',')[1]
    fruit = fruit_class.constantize.find(fruit_id.to_i)

    resource.attached_to_fruit = fruit
    resource.save
    flash[:notice] = 'Attachment updated successfully!'
    redirect_to attachment_path(resource) 
  end

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
          collection: seed.issue.all_seeds.map{|o| [o.name, o.to_global_id.to_s] },
          include_blank: true
      else
        f.input :attached_to_fruit_gid, as: :select,
          collection: f.object.person.fruits.map{|o| [o.name, o.to_global_id.to_s] },
          include_blank: true
      end
    end

    f.actions
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
      row :person
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
