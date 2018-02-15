class Seed::SeedCreator
  def self.call(klass, attributes, issue)
    seed = klass.constantize.new(attributes)
    seed.issue = issue
    seed.save
    seed
  end  
end