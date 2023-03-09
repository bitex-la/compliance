module InvoicingDetail
  class CreateNormalizedTaxIdAlerts
    def self.call(invoicing_seed)
      new(invoicing_seed).process_request
    end
  
    attr_reader :invoicing_seed, :invoicing_class
  
    def initialize(invoicing_seed)
      @invoicing_seed = invoicing_seed
      @invoicing_class = Object.const_get(invoicing_seed.class.name)
    end
  
    def process_request
      tax_id_duplicates = search_duplicates_normalized_tax_id
      return if tax_id_duplicates.empty?
  
      create_risk_score(tax_id_duplicates)
      create_related_affinities(tax_id_duplicates)
    end
  
    private
  
    def tax_id_normalized
      invoicing_seed&.tax_id&.delete(invoicing_seed.tax_id_regx) || ''
    end
  
    def search_duplicates_normalized_tax_id
      inner_join_query = "INNER JOIN issues ON issues.id = #{ invoicing_class.name.underscore }s.issue_id and issues.person_id != #{ invoicing_seed.issue.person_id }"
      invoicing_class.joins(inner_join_query).select(:issue_id).where("tax_id_normalized = '#{ tax_id_normalized }'")
    end
  
    def create_risk_score(tax_id_duplicates)
      external_links = tax_id_duplicates.select{ |item| item.issue.person_id != invoicing_seed.person_id }.map { | issue |
                                                 "/people/#{issue.issue.person_id}" }.join(',')
  
      RiskScoreSeed.create(issue_id: invoicing_seed.issue_id, score: 'High', provider: 'Compliance Legacy',
                           extra_info: 'El TAX ID ingresado por el usuario ya se encuentra registrado',
                           external_link: external_links)
    end
  
    def create_related_affinities(tax_id_duplicates)
      tax_id_duplicates.each do |item|
        next if item.issue.person_id == invoicing_seed.person_id
  
        AffinitySeed.create(issue_id: invoicing_seed.issue_id, affinity_kind_id: AffinityKind.compliance_liaison.id, related_person_id: item.person.id)
      end
    end
  end
end
