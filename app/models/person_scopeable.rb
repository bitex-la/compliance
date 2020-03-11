module PersonScopeable
  extend ActiveSupport::Concern

  class_methods do
    def default_scope
      unless (tags = AdminUser.current_admin_user&.active_tags)
        return nil
      end

      return nil if tags.empty?

      where(person_id: Person.all)
    end
  end
end
