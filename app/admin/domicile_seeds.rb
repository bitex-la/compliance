ActiveAdmin.register DomicileSeed do
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
    permit_params :country, :state, :city, :street_address, :street_number, :postal_code, :floor, :apartment, :issue_id

    form do |f|
      f.inputs "Create new domicile seed" do
        f.input :issue, required: true
        f.input :country
        f.input :state
        f.input :city
        f.input :street_address
        f.input :street_number
        f.input :postal_code
        f.input :floor
        f.input :apartment
      end
      f.actions
    end
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :issue
      row :country
      row :state
      row :city
      row :street_address
      row :street_number
      row :postal_code
      row :floor
      row :apartment
    end 

    if domicile_seed.attachments.count > 0
      panel 'Attachments' do
        table_for domicile_seed.attachments do |a|
          a.column("ID") do |attachment|
            link_to(attachment.id, admin_attachment_path(attachment))
          end
          a.column("File Name")    { |attachment| attachment.document_file_name }
          a.column("Content Type") { |attachment| attachment.document_content_type }
          a.column("File Size")    { |attachment| attachment.document_file_size }
          a.column("") { |attachment|
            link_to "View file", attachment.document.url, target: '_blank'
          }
          a.column("") { |attachment|
            link_to("View detail", admin_attachment_path(attachment))
          }
          a.column("") { |attachment|
            link_to("Edit", edit_admin_attachment_path(attachment))
          }
        end
      end
    end
  end

end
