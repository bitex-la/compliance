module DownloadProfile
  extend ActiveSupport::Concern

  def process_download_profile(resource, kind)
    EventLog.log_entity!(resource, AdminUser.current_admin_user, kind)

    zip_name = "person_#{resource.id}_kyc_files.zip"
    headers['Content-Disposition'] = "attachment; filename=\"#{zip_name.gsub('"', '\"')}\""

    zip_tricks_stream do |zip|
      files = resource.all_attachments.map { |a| [a.document, a.document_file_name] }
      files.each do |f, name|
        zip.write_deflated_file(name) do |sink|
          if f.options[:storage] == :filesystem
            stream = File.open(f.path)
            IO.copy_stream(stream, sink)
            stream.close
          else
            the_remote_uri = URI(f.expiring_url)
            Net::HTTP.get_response(the_remote_uri) do |response|
              response.read_body do |chunk|
                sink << chunk
              end
            end
          end
        end
      end

      pdf = if kind == EventLogKind.download_profile_basic
              resource.generate_pdf_profile(false, false)
            else
              resource.generate_pdf_profile(true, true)
            end

      zip.write_deflated_file('profile.pdf') do |sink|
        sink << pdf.render
      end
    end
  end
end
