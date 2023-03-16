namespace :normalization do
  task normalize_identifications: :environment do

    def normalize_invoicing_tax_ids
      [ ArgentinaInvoicingDetailSeed, ArgentinaInvoicingDetail,
        ChileInvoicingDetailSeed, ChileInvoicingDetail ].each do | klass |
        puts ' '
        puts "Running for #{ klass.name }"
        puts '-----------------'

        klass.find_each do | seed |
          normalize_tax_id = seed.normalize_tax_id 
          puts "Updating seed #{ seed.id } - normalize_tax_id => #{ normalize_tax_id }"
          seed.update_columns(tax_id_normalized: normalize_tax_id)
        end
      end
    end

    def normalize_identification_numbers
      [ IdentificationSeed, Identification ].each do | klass |
        puts ' '
        puts "Running for #{ klass.name }"
        puts '-----------------'

        klass.where(issuer: ['AR', 'CL']).find_each do | seed |
          normalize_number = seed.normalize_number
          puts "Updating seed #{ seed.id } - normalize_number => #{ normalize_number }"
          seed.update_columns(number_normalized: normalize_number)
        end
      end
    end
    
    puts '-----------------------'
    puts ' TAX ID NORMALIZATION'
    puts '-----------------------'
    normalize_invoicing_tax_ids
    normalize_identification_numbers
  end
end
