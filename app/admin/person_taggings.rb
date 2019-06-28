ActiveAdmin.register PersonTagging do
  menu false
  actions :destroy

  controller do
    def destroy
      super do |f| 
        f.html { redirect_to edit_person_url(resource.person) } 
      end
    end
  end
end