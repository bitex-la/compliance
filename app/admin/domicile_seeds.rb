ActiveAdmin.register DomicileSeed do
  menu false

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_issue_url(issue)
    end
  end

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
end
