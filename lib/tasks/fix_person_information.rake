namespace :reconciliation_tasks do
  task fix_argentina_full_names: :environment do
    def fix_for_klass(klass, extract_natural_docket_information, update_block)
      puts "Running fix for #{klass}"

      klass
        .where(full_name: ',')
        .select do |invoicing|
          docket = extract_natural_docket_information.call(invoicing)
          docket.first_name&.present? && docket.last_name&.present?
        end
        .each do |invoicing|
        puts "Attempting to fix #{invoicing.class}##{invoicing.id}"
        docket = extract_natural_docket_information.call(invoicing)
        full_name = "#{docket.first_name}, #{docket.last_name}"
        update_block.call(invoicing, full_name)
      rescue => e
        puts "Cannot fix #{invoicing.class}##{invoicing.id}. #{e.message}"
      end

      puts "Finished run for #{klass}"
    end

    fix_for_klass(ArgentinaInvoicingDetail,
                  ->(invoicing) { invoicing.person.natural_docket },
                  ->(invoicing, full_name) { invoicing.update!(full_name: full_name)})
    fix_for_klass(ArgentinaInvoicingDetailSeed,
                  ->(invoicing) { invoicing.issue.natural_docket_seed },
                  ->(invoicing, full_name) { invoicing.update_columns(full_name: full_name)})
  end
end
