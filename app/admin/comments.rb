ActiveAdmin.register Comment do
  belongs_to :issue
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
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
