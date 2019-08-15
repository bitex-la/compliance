ActiveAdmin.register Task do
  menu false
  belongs_to :workflow
  actions :all, except: [:index, :new, :edit]
end