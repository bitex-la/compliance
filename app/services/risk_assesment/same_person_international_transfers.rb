module RiskAssesment
  class SamePersonInternationalTransfers
    def self.call(person)
      person.reload
      withdrawal_countries = person.fund_withdrawals.pluck(:country)
      deposits_countries = person.fund_deposits.where.not(country: nil).pluck(:country)

      countries = (deposits_countries + withdrawal_countries).uniq

      return if countries.length <= 1

      risk_score = existing_risk_score(person)

      return if risk_score && same_countries_in_risk_score(risk_score, countries)

      create_issue(person, countries, risk_score)
    end

    def self.same_countries_in_risk_score(risk_score, countries)
      extra_info = JSON.parse(risk_score.extra_info)

      return extra_info['countries'] && (countries - extra_info['countries']).empty?
    end

    def self.create_issue(person, countries, risk_score)
      issue = person.issues.build

      withdrawals_sum, withdrawals_count = person
                                             .fund_withdrawals
                                             .where(country: countries)
                                             .pluck(Arel.sql('sum(exchange_rate_adjusted_amount), count(*)'))
                                             .first

      deposits_sum, deposits_count = person
                                       .fund_deposits
                                       .where(country: countries)
                                       .pluck(Arel.sql('sum(exchange_rate_adjusted_amount), count(*)'))
                                       .first

      issue.risk_score_seeds.build(
        replaces: risk_score,
        provider: 'open_compliance',
        score: 'same_person_international_transfers',
        extra_info: {
          fund_withdrawals_count: withdrawals_count,
          fund_withdrawals_sum: withdrawals_sum,
          fund_deposits_count: deposits_count,
          fund_deposits_sum: deposits_sum,
          countries: countries
        }.to_json
      )

      issue.save!
      issue.complete!
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