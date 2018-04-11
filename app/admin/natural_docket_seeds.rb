ActiveAdmin.register NaturalDocketSeed do
  menu false

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_person_issue_url(issue.person, issue)
    end
  end

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

      ArbreHelpers.attachments_panel(self, resource.attachments)
    end
  end
end
