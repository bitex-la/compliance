module CountryTagsCleaner
  def self.perform!
    Rails.logger.info 'Starting clean'

    tags_ids = Tag.where(tag_type: :person)
      .where("name like 'active-in-%'").pluck(:id)

    Rails.logger.info "Tags to clean: #{tags_ids}"

    PersonTagging.where(tag_id: tags_ids).delete_all

    Rails.logger.info 'Clean finished'
  end
end
