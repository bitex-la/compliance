module RiskAssesment
  class SamePersonInternationalTransfers
    def self.call(person)
      withdrawal_countries = person.fund_withdrawals.pluck(:country)
      deposits_countries = person.fund_deposits.where.not(country: nil).pluck(:country)

      return if deposits_countries.empty? || withdrawal_countries.empty?

      unmatched_countries = withdrawal_countries - deposits_countries |
                            deposits_countries - withdrawal_countries

      return if unmatched_countries.empty?

      create_issue(person, unmatched_countries)
    end

    def self.create_issue(person, unmatched_countries)
      issue = person.issues.build

      fund_withdrawals = person
                          .fund_withdrawals
                          .where(country: unmatched_countries)
      fund_deposits = person
                        .fund_deposits
                        .where(country: unmatched_countries)

      issue.risk_score_seeds.build(
        replaces: existing_risk_score(person),
        provider: 'open-compliance',
        score: 'same_person_international_transfers',
        extra_info: {
          fund_withdrawals_count: fund_withdrawals.count,
          fund_withdrawals_sum: fund_withdrawals.sum(:exchange_rate_adjusted_amount),
          fund_deposits_count: fund_deposits.count,
          fund_deposits_sum: fund_deposits.sum(:exchange_rate_adjusted_amount)
        }.to_json
      )

      issue.save!
      issue.approve!
    end

    def self.existing_risk_score(person)
      person
        .risk_scores
        .find_by(
          provider: 'open_compliance',
          score: 'same_person_international_transfers'
        )
    end
  end
end