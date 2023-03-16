module NormalizedIdentificationAlerts
  class NormalizedIdentificationAlertsBase

    def self.call(seed)
      new(seed).process_request
    end
  
    attr_reader :seed, :seed_class
  
    def initialize(seed)
      @seed = seed
      @seed_class = seed.class
    end
    
    def process_request
      duplicates = search_duplicates
      return if duplicates&.empty?

      create_risk_score(duplicates)
      create_related_affinities(duplicates)
    end

    private

    def search_query(klass, params)
      klass.joins(inner_join_query(klass)).select(:issue_id).where(params)
    end

    def inner_join_query(klass)
      "INNER JOIN issues ON issues.id = #{ klass.table_name }.issue_id and issues.person_id != #{ seed.issue.person_id }"
    end
    
    def create_risk_score(duplicates)
      external_links = duplicates.select{ |item| item.issue.person_id != seed.person_id }.map { | issue |
                                                 "/people/#{issue.issue.person_id}" }.uniq.join(',')

      RiskScoreSeed.create(issue_id: seed.issue_id, score: 'High', provider: 'Compliance Legacy',
                           extra_info: 'El TAX ID ingresado por el usuario ya se encuentra registrado',
                           external_link: external_links)
    end

    def create_related_affinities(duplicates)
      duplicates.each do |item|
        next if item.issue.person_id == seed.person_id

        AffinitySeed.create(issue_id: seed.issue_id, affinity_kind_id: AffinityKind.compliance_liaison.id, related_person_id: item.person.id)
      end
    end
    
  end
end
