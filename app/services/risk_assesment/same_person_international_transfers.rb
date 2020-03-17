module RiskAssesment
  class SamePersonInternationalTransfers
    def self.call(person)
      withdrawal_countries = person.fund_withdrawals.pluck(:country)
      deposits_countries = person.fund_deposits.where.not(country: nil).pluck(:country)

      return if deposits_countries.empty? || withdrawal_countries.empty?

      unmatched_deposits_countries = deposits_countries - withdrawal_countries
      unmatched_withdrawals_countries = withdrawal_countries - deposits_countries

      unmatched_countries = unmatched_withdrawals_countries |
                            unmatched_deposits_countries

      return if unmatched_countries.empty?

      create_issue(person, unmatched_countries, unmatched_withdrawals_countries, unmatched_deposits_countries)
    end

    def self.create_issue(person, unmatched_countries, unmatched_withdrawals_countries, unmatched_deposits_countries)
      issue = person.issues.build

      fund_withdrawals = person
                          .fund_withdrawals
                          .where(country: unmatched_countries)
      fund_deposits = person
                        .fund_deposits
                        .where(country: unmatched_countries)

      issue.risk_score_seeds.build(
        provider: 'open-compliance',
        score: 'same_person_international_transfers',
        extra_info: {
          fund_withdrawals_count: fund_withdrawals.count,
          fund_withdrawals_sum: fund_withdrawals.sum(:exchange_rate_adjusted_amount),
          fund_deposits_count: fund_deposits.count,
          fund_deposits_sum: fund_deposits.sum(:exchange_rate_adjusted_amount),
          fund_withdrawals_countries: unmatched_withdrawals_countries.uniq,
          fund_deposits_countries: unmatched_deposits_countries.uniq
        }.to_json
      )

      issue.save!
      issue.complete!
    end
  end
end