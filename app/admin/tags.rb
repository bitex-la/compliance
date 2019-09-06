ActiveAdmin.register Tag do
  menu

  filter :name
  filter :tag_type, as: :select, collection: Tag.tag_types
  filter :created_at
  filter :updated_at

  controller do
    def destroy
      super
      flash[:alert] = resource.errors.full_messages.join('-') unless resource.errors.full_messages.empty?
    end
  end
end