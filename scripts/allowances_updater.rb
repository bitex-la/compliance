module AllowancesUpdater
  def self.perform!
    tag = Tag.where(name: 'active-in-AR').first
    Person.joins(:person_taggings).where(person_taggings: { tag: tag })
      .find_each do |person|

      Rails.logger.info "Processing person #{person.id}"

      next unless person.allowances.empty? ||
        person.allowances.all? { |a| a.amount.nil? || a.amount.zero? }

      issue = person.issues.create

      if person.allowances.empty?
        issue.allowance_seeds.create(amount: 25_000.0, kind: Currency.ars)
      else
        person.allowances.select { |a| a.amount.nil? || a.amount.zero? }.each do |a|
          issue.allowance_seeds.create(amount: 25_000.0, kind: Currency.ars, replaces: a)
        end
      end

      issue.save!
      issue.approve!

      Rails.logger.info "Approved issue #{issue.id} for person #{person.id}"
    end
    Rails.logger.info 'End of job'
  end
end
