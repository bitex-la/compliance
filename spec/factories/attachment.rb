FactoryBot.define do
   %i(jpg png gif pdf zip
   ).each do |type|
    factory "#{type}_attachment", class: Attachment do
      document { File.new("#{Rails.root}/spec/fixtures/files/simple.#{type}") }
    end
  end
end
