ActiveAdmin.register Note do
  menu false
  actions :all, :except => [:edit, :destroy]
end
