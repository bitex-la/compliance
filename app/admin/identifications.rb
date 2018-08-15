ActiveAdmin.register Identification do
  includes :identification_seed, :attachments

  menu false
  actions :all, :except => [:edit, :destroy]

  show do 
    ArbreHelpers.fruit_show_page(self)
  end
end
