module TagsUpdater
  def self.perform
    Person.find_each do |person|
      Rails.logger.info "Processing person #{person.id}"
      countries = person.fund_deposits.pluck(:country)
      countries << person.fund_withdrawals.pluck(:country)
      countries << person.argentina_invoicing_details.try(:country)
      countries << person.chile_invoicing_details.try(:country)
      countries << person.domiciles.pluck(:country)
      countries.flatten.compact.uniq.each do |country|
        person.refresh_person_country_tagging!(country)
      end
    end
    Rails.logger.info "End of job"
  end
end
