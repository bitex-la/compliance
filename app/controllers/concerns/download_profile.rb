# frozen_string_literal: true

require 'zip'

module DownloadProfile
  extend ActiveSupport::Concern

  def process_download_profile(resource, kind)
    EventLog.log_entity!(resource, AdminUser.current_admin_user, kind)

    zip = Tempfile.new('', "#{Rails.root}/tmp/")

    files = resource.all_attachments.map { |a| [a.id, a.document, a.document_file_name] }

    begin
      Zip::OutputStream.open(zip) { |zos| }

      Zip::File.open(zip.path, Zip::File::CREATE) do |zipfile|
        files.each do |id, f, name|
          if f.options[:storage] == :filesystem
            zipfile.add("#{id}_#{name}", f.path)
          else
            zipfile.get_output_stream("#{id}_#{name}") { |z| z.write open(f.expiring_url, 'rb').read }
          end
        end

        if kind == EventLogKind.download_profile_history
          file_name_suffix = 'history'
          profile_csv = resource.generate_profile_history_csv
          zipfile.get_output_stream('profile_history.csv') { |f| f.write profile_csv }
          observations_csv = resource.generate_observations_history_csv
          zipfile.get_output_stream('observations_history.csv') { |f| f.write observations_csv }
        else
          file_name_suffix = 'kyc_files'
          pdf =
            if kind == EventLogKind.download_profile_basic
              resource.generate_pdf_profile(false, false)
            else
              resource.generate_pdf_profile(true, true)
            end

          zipfile.get_output_stream('profile.pdf') { |f| f.write pdf.render }
        end
      end
      send_data File.read(zip.path), type: 'application/zip',
        filename: "person_#{resource.id}_#{suffix}.zip"
    ensure
      zip.close
      zip.unlink
    end
  end
end
