require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

module FactoryBot
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

            after(:create) do |thing, evaluator|
              next unless evaluator.add_all_attachments
              %i(bmp jpg png gif pdf zip BMP JPG PNG GIF PDF).each do |name|
                create "#{name}_attachment", thing: thing
              end
            end

            factory("#{factory_name}_seed", class: seed_class) do
              factory "#{factory_name}_seed_with_issue" do
                association :issue, factory: :basic_issue
              end
            end
            
            factory factory_name do 
              after(:create) do |resource, evaluator|
                create("#{factory_name}_seed",
                  issue: resource.person.issues.reload.first,
                  fruit: resource)
              end

              factory "#{factory_name}_with_person" do
                association :person, factory: [:empty_person, :with_issue]
              end
            end
          end
        end
      end
    end
  end
end
