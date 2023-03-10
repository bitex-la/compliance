namespace :normalization do
  task normalize_tax_ids: :environment do

    def normalize_tax_ids
      [ ArgentinaInvoicingDetailSeed, ArgentinaInvoicingDetail,
        ChileInvoicingDetailSeed, ChileInvoicingDetail ].each do | klass |
        puts ' '
        puts "Running for #{ klass.name }"
        puts '-----------------'

        limit = 500
        offset = 0
        running = true

        while running
          invoicing_seeds = klass.order(:id).limit(limit).offset(offset)
          
          invoicing_seeds.each do | seed |
            puts "Updating seed #{ seed.id } - normalize_tax_id => #{ seed.normalize_tax_id }"
            ActiveRecord::Base.connection.execute("update #{ klass.name.underscore }s set tax_id_normalized = '#{ seed.normalize_tax_id }' where id = #{ seed.id }")
          end

          offset += limit
          running = !invoicing_seeds.empty?
        end
      end
    end
    
    puts '-----------------------'
    puts ' TAX ID NORMALIZATION'
    puts '-----------------------'
    normalize_tax_ids
  end
end
