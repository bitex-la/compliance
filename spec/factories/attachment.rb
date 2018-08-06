FactoryBot.define do
  factory :attachment do
    transient do
      thing nil
    end

    attached_to_seed do
      next unless thing
      thing.class.name.include?('Seed') ? thing : thing.seed
    end

    attached_to_fruit do
      next unless thing
      thing unless thing.class.name.include?('Seed')
    end

    person do
      next unless thing
      thing.class.name.include?('Seed') ? thing.issue.person : thing.person
    end

    %i(jpg png gif pdf zip).each do |type|
      factory "#{type}_attachment", class: Attachment do
        document { File.new("#{Rails.root}/spec/fixtures/files/simple.#{type}") }
      end
    end
  end

  factory :orphan_attachment, class: Attachment do 
    document { File.new("#{Rails.root}/spec/fixtures/files/simple.jpg") }
    attached_to_seed nil
    attached_to_fruit nil
  end
end
