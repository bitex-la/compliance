module PersonScopeable
  extend ActiveSupport::Concern

  class_methods do
    def default_scope
      return unless AdminUser.current_admin_user.active_tags.presence

      collection_scoped_by_persons
    end

    def collection_scoped_by_persons
      where(person_id: Person.all)
    end
  end
end
