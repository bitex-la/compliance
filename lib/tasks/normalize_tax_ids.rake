namespace :normalization do
  task normalize_tax_ids: :environment do

    def normalize_tax_ids
      [ ArgentinaInvoicingDetailSeed, ArgentinaInvoicingDetail,
        ChileInvoicingDetailSeed, ChileInvoicingDetail ].each do | klass |
        puts ' '
        puts "Running for #{ klass.name }"
        puts '-----------------'

        klass.find_each do | seed |
          puts "Updating seed #{ seed.id } - normalize_tax_id => #{ seed.normalize_tax_id }"
          seed.update_columns(tax_id_normalized: seed.normalize_tax_id)
        end
      end
    end
    
    puts '-----------------------'
    puts ' TAX ID NORMALIZATION'
    puts '-----------------------'
    normalize_tax_ids
  end
end
