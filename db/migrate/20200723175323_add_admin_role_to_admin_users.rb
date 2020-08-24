class AddAdminRoleToAdminUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_users, :admin_role_id, :integer, null: false, default: 7 #restricted

    # old roles
    #===========
    #:restricted = 0
    #:admin = 1
    #:super_admin = 2
    #:marketing = 3
    #:admin_restricted = 4

    # new roles
    #==========
    #:admin = 1
    #:marketing = 2
    #:compliance = 3
    #:operations = 4
    #:commercial = 5
    #:security = 6
    #:restricted = 7

    # map old role to new role
    mapping.each do |k, v|
      AdminUser.where(role_type: k).update_all(admin_role_id: v)
    end

    remove_column :admin_users, :role_type
  end

  def mapping
    {
      0 => 5,
      1 => 3,
      2 => 1,
      3 => 2,
      4 => 7
    }
  end

  def down
    add_column :admin_users, :role_type, :integer, null: false, default: 0 #restricted

    # map new role to old role
    mapping.each do |k, v|
      AdminUser.where(admin_role_id: v).update_all(role_type: k)
    end

    remove_column :admin_users, :admin_role_id
  end
end
