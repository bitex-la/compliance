ActiveAdmin.register IdentificationSeed do
  menu false

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_issue_url(issue)
    end
  end

  begin
    permit_params :kind, :number, :issuer, :issue_id

    form do |f|
      f.inputs "Create new identification seed" do
        f.input :issue, required: true
        f.input :kind
        f.input :number
        f.input :issuer
      end
      f.actions
    end

    show do
      attributes_table do
        row :id
        row :created_at
        row :updated_at
        row :issue
        row :kind
        row :number
        row :issuer
      end

      ArbreHelpers.attachments_panel(self, resource.attachments)
    end   
  end
end
