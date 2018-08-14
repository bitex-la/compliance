ActiveAdmin.register Email do
  menu false
  actions :all, :except => [:edit, :destroy]
end
