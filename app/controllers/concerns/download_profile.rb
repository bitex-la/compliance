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
            zipfile.get_output_stream("#{id}_#{name}") { |z| z.print open(f.expiring_url, 'rb') }
            #zipfile.get_output_stream("#{id}_#{name}") { |z| z.print(URI.parse(f.expiring_url).read) }
          end
        end

        pdf = if kind == EventLogKind.download_profile_basic
                resource.generate_pdf_profile(false, false)
              else
                resource.generate_pdf_profile(true, true)
              end

        zipfile.get_output_stream('profile.pdf') { |f| f.write pdf.render }
      end
      send_data File.read(zip.path), type: 'application/zip',
        filename: "person_#{resource.id}_kyc_files.zip"
    ensure
      zip.close
      zip.unlink
    end
  end
end
