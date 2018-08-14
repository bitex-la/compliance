ActiveAdmin.register Identification do
  menu false

  show do 
    columns do
      column span: 2 do
        ArbreHelpers.fruit_attribute_table(self, resource) do
          row :number
          row :identification_kind
          row :issuer
          row :public_registry_authority 
          row :public_registry_book
          row :public_registry_data
        end
        ArbreHelpers.attachments_panel(self, resource.attachments)
      end

      column do 
        ArbreHelpers.fruit_relations_panels(self, resource)
      end 
    end  
  end
end
