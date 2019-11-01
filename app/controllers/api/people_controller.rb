class Api::PeopleController < Api::ApiController
  include ZipTricks::RailsStreaming

  caches_action :show, expires_in: 2.minutes, cache_path: :path_for_show

  def index
    scope = Person.ransack(params[:filter]).result
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = scope.page(page).per(per_page)
    jsonapi_response( people,
      meta: {
        total_pages: (scope.count.to_f / per_page).ceil,
        total_items: scope.count
      }
    )
  end

  def show
    jsonapi_response Person.find(params[:id]), {}
  end

  def create
    return jsonapi_response Person.create, {}, 201 if params[:data].nil?

    mapper = JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:tags],
      people: [:enabled, :risk, :tags, id: nil ],
      tags: []

    return jsonapi_422 unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data,{}, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  def update
    mapper = JsonapiMapper.doc_unsafe!(
      params.permit!.to_h, [:people], people: %I[enabled risk])

    return jsonapi_422 unless mapper.data

    if mapper.data.save
      jsonapi_response mapper.data, {}, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  Person.aasm.events.map(&:name).each do |action|
    define_method(action) do
      person = Person.find(params[:id])
      begin        
        return jsonapi_error(422, "invalid transition") unless can_run_transition(person, action)

        person.aasm.fire!(action)
        jsonapi_response(person, {}, 200)
      rescue AASM::InvalidTransition => e
        jsonapi_error(422, "invalid transition")
      end
    end
  end

  def download_profile
    person = Person.find(params[:id])
    process_download_profile person, EventLogKind.download_profile_basic
  end

  protected

  def process_download_profile(resource, kind)
    EventLog.log_entity!(resource, AdminUser.current_admin_user, kind)

    zip_name = "person_#{resource.id}_kyc_files.zip"
    headers['Content-Disposition'] = "attachment; filename=\"#{zip_name.gsub '"', '\"'}\""

    zip_tricks_stream do |zip|
      files = resource.all_attachments.map { |a| [a.document, a.document_file_name] }
      files.each do |f, name|
        zip.write_deflated_file(name) do |sink|
          if f.options[:storage] == :filesystem
            stream = File.open(f.path)
            IO.copy_stream(stream, sink)
            stream.close
          else
            the_remote_uri = URI(file.expiring_url)
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

  def can_run_transition(person, action)
    !((action == :enable || action == :disable) && person.state == "rejected")
  end

  def path_for_show
    "person/show/#{params[:id]}?#{params.permit!.to_query}"
  end
end
