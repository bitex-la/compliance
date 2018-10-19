#FruitAdmin.register RiskScore

ActiveAdmin.register RiskScore do
  menu false
  actions :all, :except => [:edit, :destroy]

  show do 
    attributes_table_for resource do
      row(:show){|o| link_to o.name, o }
      row(:score)
      row(:provider)
      row(:extra_info)
      row(:external_links) do |f|
        ArbreHelpers.show_links(self, f.external_link.split(',').compact)
      end
      if resource.replaces
        row(:replaces)
      end
      row(:created_at)
      row(:issue)
    end
  end
end
