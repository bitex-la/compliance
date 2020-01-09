class FruitAdmin
  def self.register(klass)
    ActiveAdmin.register klass do
      menu false
      actions :show
      includes :issue

      breadcrumb do
        []
      end

      controller do
        def related_person
          resource.person_id
        end
      end

      show do
        ArbreHelpers::Fruit.fruit_show_page(self)
      end
    end
  end
end
