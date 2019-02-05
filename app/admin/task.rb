ActiveAdmin.register Task do
  belongs_to :workflow
  actions :all, except: :destroy 
end