ActiveAdmin.register Tag do
  filter :name
  filter :tag_type, as: :select, collection: Tag.tag_types
  filter :created_at
  filter :updated_at
end