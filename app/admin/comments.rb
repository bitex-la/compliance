ActiveAdmin.register Comment do
  menu false
  actions :destroy

  controller do
    def destroy
      super do |f| 
        f.html  { redirect_to url_for(resource.commentable) }
      end
    end
  end
end