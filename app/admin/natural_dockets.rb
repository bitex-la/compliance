ActiveAdmin.register NaturalDocket do
  includes :natural_docket_seed, :attachments
  menu false
  actions :all, :except => [:edit, :destroy]

  show do 
    ArbreHelpers.fruit_show_page(self)
  end
end
