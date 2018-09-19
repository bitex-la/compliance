class FruitAdmin
  def self.register(klass)
    ActiveAdmin.register klass do
      menu false
      actions :all, :except => [:edit, :destroy]

      show do 
        ArbreHelpers.fruit_show_page(self)
      end
    end
  end
end
