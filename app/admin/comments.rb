ActiveAdmin.register Comment do
  #belongs_to :person
  menu false
  
  begin
    permit_params :id, :title, :body, :commentable_id

    form do |f|
      f.inputs "Post new comment" do
        f.input :title, required: true
        f.input :body, required: true
      end
      f.actions
    end
  end
end
