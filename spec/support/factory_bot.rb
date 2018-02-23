require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

module FactoryBot
  # Creates factories for resources and their seeds based
  # on their common attributes.
  # The main difference between resources and their seeds
  # is that resources point to a person and seeds point to an issue.
  # These factories assume:
  #   * Resources and Seeds are consistently named.
  #   * Seeds point to a resource with a singularized accesor.
  #   * Resources will receive a person on creation.
  #   * Seeds will receive an issue on creation.
  def self.define_persons_item_and_seed(resource_name, factories)
    seed_class = "#{resource_name.to_s.classify}Seed".constantize
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
