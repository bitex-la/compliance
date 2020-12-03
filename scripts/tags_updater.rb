module TagsUpdater
  def self.perform
    Person.find_each do |person|
      from_date = Date.new(2020, 1, 1)

      filter = ['AR', 'CL', 'UY', 'PY']

      Rails.logger.info "Processing person #{person.id}"
      countries = 'AN'
      countries << person.fund_deposits.where(country: filter)
        .where('deposit_date >= ?', from_date)
        .pluck(:country)
      countries << person.fund_withdrawals.where(country: filter)
        .where('withdrawal_date >= ?', from_date)
        .pluck(:country)
      countries.flatten.compact.uniq.each do |country|
        person.refresh_person_country_tagging!(country)
      end
    end
    Rails.logger.info 'End of job'
  end
end
