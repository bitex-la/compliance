namespace :reconciliation_tasks do
  task fix_argentina_full_names: :environment do
    def fix_for_klass(klass)
      puts "Running fix for #{klass}"

      def extract_first_name(invoicing)
        return invoicing.issue.natural_docket_seed.first_name if invoicing.is_a?(ArgentinaInvoicingDetailSeed)
        return invoicing.person.natural_docket.first_name if invoicing.is_a?(ArgentinaInvoicingDetail)
      end

      def extract_last_name(invoicing)
        return invoicing.issue.natural_docket_seed.last_name if invoicing.is_a?(ArgentinaInvoicingDetailSeed)
        return invoicing.person.natural_docket.last_name if invoicing.is_a?(ArgentinaInvoicingDetail)
      end

      klass
        .where(full_name: ',')
        .select { |invoicing| extract_first_name(invoicing).present? && extract_last_name(invoicing).present? }
        .each do |invoicing|
        puts "Attempting to fix #{invoicing.class}##{invoicing.id}"
        invoicing.update!(full_name: "#{extract_first_name(invoicing)}, #{extract_last_name(invoicing)}")
      rescue => e
        puts "Cannot fix #{invoicing.class}##{invoicing.id}. #{e.message}"
      end

      puts "Finished run for #{klass}"
    end

    fix_for_klass(ArgentinaInvoicingDetail)
    fix_for_klass(ArgentinaInvoicingDetailSeed)
  end
end
