module TagsUpdater
  def self.perform!
    from_date = Date.new(2020, 1, 1)
    country_filter = ['AR', 'CL', 'UY', 'PY']

    Person.find_each do |person|
      Rails.logger.info "Processing person #{person.id}"

      countries = ['AN']
      countries << person.fund_deposits.where(country: country_filter)
        .where('deposit_date >= ?', from_date)
        .pluck(:country)
      countries << person.fund_withdrawals.where(country: country_filter)
        .where('withdrawal_date >= ?', from_date)
        .pluck(:country)

      Rails.logger.info "Countries to add #{countries}"

      countries.flatten.compact.uniq.each do |country|
        person.refresh_person_country_tagging!(country)
      end
    end
    Rails.logger.info 'End of job'
  end
end
