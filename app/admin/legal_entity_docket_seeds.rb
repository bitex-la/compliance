ActiveAdmin.register LegalEntityDocketSeed do
  menu false

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_person_issue_url(issue.person, issue)
    end
  end

  begin
    permit_params :industry, :business_description, :country, :commercial_name, :legal_name, :issue_id

    form do |f|
      f.inputs "Create new legal entity docket seed" do
        f.input :issue, required: true
        f.input :industry
        f.input :business_description
        f.input :country
        f.input :commercial_name
        f.input :legal_name
      end
      f.actions
    end

    show do
      attributes_table do
        row :id
        row :created_at
        row :updated_at
        row :issue
        row :industry
        row :business_description
        row :country
        row :commercial_name
        row :legal_name
      end

      ArbreHelpers.attachments_panel(self, resource.attachments)
    end
  end
end
