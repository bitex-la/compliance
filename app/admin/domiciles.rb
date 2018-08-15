ActiveAdmin.register Domicile do
  menu false
  actions :all, :except => [:edit, :destroy]

  show do 
    ArbreHelpers.fruit_show_page(self)
  end
end
