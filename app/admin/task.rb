ActiveAdmin.register Task do
  menu false
  belongs_to :workflow
  actions :all, except: [:index, :new, :edit]

  controller do
    def related_person
      resource.issue.person_id
    end
  end
end