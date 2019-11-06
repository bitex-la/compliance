class FruitAdmin
  def self.register(klass)
    ActiveAdmin.register klass do
      menu false
      actions :all, :except => [:edit, :destroy]

      controller do
        def related_person
          resource.issue.person_id
        end
      end

      show do
        ArbreHelpers::Fruit.fruit_show_page(self)
      end
    end
  end
end
