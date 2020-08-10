FactoryBot.define do
  factory :attachment do
    transient do
      thing { nil }
    end

    attached_to_seed do
      next unless thing
      thing.class.name.include?('Seed') ? thing : thing.seed
    end

    attached_to_fruit do
      next unless thing
      thing unless thing.class.name.include?('Seed')
    end

    person_id do
      next unless thing
      thing.class.name.include?('Seed') ? thing.issue.person_id : thing.person_id
    end

    %i(bmp jpg png gif pdf zip).each do |type|
      factory "#{type}_attachment", class: Attachment do
        document { File.new("#{Rails.root}/spec/fixtures/files/simple.#{type}") }
      end
    end

    %i(BMP JPG PNG GIF PDF ZIP).each do |type|
      factory "#{type}_attachment", class: Attachment do
        document { File.new("#{Rails.root}/spec/fixtures/files/simple_upper.#{type}") }
      end
    end
  end
end
