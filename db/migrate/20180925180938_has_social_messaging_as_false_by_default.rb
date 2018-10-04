class HasSocialMessagingAsFalseByDefault < ActiveRecord::Migration[5.1]
  def change
    change_column :phone_seeds, :has_whatsapp, :boolean, default: false
    change_column :phone_seeds, :has_telegram, :boolean, default: false 
    change_column :phones, :has_whatsapp, :boolean, default: false
    change_column :phones, :has_telegram, :boolean, default: false  
  end
end
