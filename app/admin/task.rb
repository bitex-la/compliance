ActiveAdmin.register Task do
  menu false
  belongs_to :workflow
  actions :all, except: [:index, :new, :edit]

  controller do
    def related_person
      resource.workflow.issue.person_id
    end

    def scoped_collection
      super.eager_load(:workflow, workflow: :issue)
    end
  end
end
