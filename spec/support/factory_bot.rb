require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

module FactoryBot
  def self.get_person_from_thing(thing)
    thing.class.name.include?("Seed") ? thing.issue.person : thing.person
  end
  
  # See garden.rb for more details about the Garden, Seed and Fruit metaphor.
  def self.define_persons_item_and_seed(resource_name, factories)
    seed_class = Garden::Naming.new(resource_name).seed
    define do
      factory resource_name do
        factory "#{resource_name}_seed", class: seed_class do
          association :issue, factory: :basic_issue
        end
        
        factories.each do |factory_name, block|
          factory "#{factory_name}_base" do
            instance_eval(&block)

            factory("#{factory_name}_seed", class: seed_class)
            
            factory factory_name do 
              after(:create) do |resource, evaluator|
                create("#{factory_name}_seed",
                  issue: resource.person.issues.first,
                  fruit: resource)
              end
            end
          end
        end
      end
    end
  end
end
