ActiveAdmin.register DomicileSeed do
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

    ArbreHelpers.attachments_panel(self, resource.attachments)
  end
end
