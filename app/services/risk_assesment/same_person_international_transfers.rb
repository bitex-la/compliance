module RiskAssesment
  class SamePersonInternationalTransfers
    def self.call(person)
      withdrawal_countries = person.fund_withdrawals.pluck(:country)
      deposits_countries = person.fund_deposits.where.not(country: nil).pluck(:country)

      unmatched_countries = withdrawal_countries - deposits_countries |
                            deposits_countries - withdrawal_countries

      return if unmatched_countries.empty?

      create_issue(person)
    end

    def self.create_issue(person)
      issue = person.issues.create

      issue.risk_score_seeds.create(
        replaces: existing_risk_score(person),
        provider: 'open-compliance',
        score: 'same_person_international_transfers',
        extra_info: {
          fund_withdrawals_count: person.fund_withdrawals.count,
          fund_withdrawals_sum: person.fund_withdrawals.sum(:exchange_rate_adjusted_amount),
          fund_deposits_count: person.fund_deposits.count,
          fund_deposits_sum: person.fund_deposits.sum(:exchange_rate_adjusted_amount)
        }
      )

      issue.approve!
    end

    def self.existing_risk_score(person)
      person
        .risk_scores
        .select do |r|
          r.provider == 'open_compliance' &&
          r.score == 'same_person_international_transfers'
        end[0]
    end
  end
end