ActiveAdmin.register NaturalDocket do
  menu false
  actions :all, :except => [:edit, :destroy]

  show do 
    columns do
      column do
        attributes_table do
          row :id
          row :created_at
          row :updated_at
        end
        ArbreHelpers.attachments_panel(self, resource.attachments)
      end

      column do 
        ArbreHelpers.fruit_relations_panels(self, resource)
      end 
    end  
  end
end
