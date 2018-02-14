class Issue::SeedLinker

  AVAILABLE_SEEDS_TYPES = [
    :domicile_seeds,
    :identification_seeds
  ]

  def self.call(issue, relationships)
    AVAILABLE_SEEDS_TYPES.each do |seed_type|
      if !relationships[seed_type].empty?
        relationships[seed_type][:data].each do |seed|
          Seed::SeedCreator.call(
            seed_type.to_s.singularize.camelize, 
            seed['attributes'], issue)
        end
      end  
    end 
    issue.reload
  end  
end  