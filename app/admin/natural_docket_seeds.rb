ActiveAdmin.register NaturalDocketSeed do
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
    permit_params :first_name, :last_name, :birth_date, :nationality, :gender, :marital_status, :issue_id

    form do |f|
      f.inputs "Create new natural docket seed" do
        f.input :issue, required: true
        f.input :first_name
        f.input :last_name
        f.input :birth_date
        f.input :nationality
        f.input :gender
        f.input :marital_status
      end
      f.actions
    end

    show do
      attributes_table do
        row :id
        row :created_at
        row :updated_at
        row :issue
        row :first_name
        row :last_name
        row :birth_date
        row :nationality
        row :gender
        row :marital_status
      end

      if natural_docket_seed.attachments.count > 0
        panel 'Attachments' do
          table_for natural_docket_seed.attachments do |a|
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
end
