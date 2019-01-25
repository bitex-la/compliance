module RequestHelpers
  def forbidden_api_request(method, path, params)
    send(method, "/api#{path}", params: params,
      headers: { 'Authorization': "Token token=potato" })
    assert_response 403
  end

  def api_request(method, path, params = {}, expected_status = 200)
    admin = AdminUser.last || create(:admin_user)
    send(method, "/api#{path}", params: params,
      headers: { 'Authorization': "Token token=#{admin.api_token}" })
    assert_response expected_status
  end

  def public_api_request(method, path, params = {}, expected_status = 200)
    person = Person.last || create(:new_natural_person)
    send(method, "/api/public#{path}", params: params,
      headers: { 'Authorization': "Token token=#{person.api_token}" })
    assert_response expected_status
  end

  def api_get(path, params = {}, expected_status = 200)
    api_request(:get, path, params, expected_status)
  end

  def api_create(path, data, expected_status = 201)
    api_request(:post, path, {data: data}, expected_status)
  end

  def api_update(path, data, expected_status = 200)
    api_request(:patch, path, {data: data}, expected_status)
  end

  def api_destroy(path, expected_status = 204)
    api_request(:delete, path, {}, expected_status)
  end

  def public_api_get(path, params = {}, expected_status = 200)
    public_api_request(:get, path, params, expected_status)
  end

  def public_api_create(path, data, expected_status = 201)
    public_api_request(:post, path, {data: data}, expected_status)
  end

  def public_api_update(path, data, expected_status = 200)
    public_api_request(:patch, path, {data: data}, expected_status)
  end

  def json_response
    JSON.parse(response.body).deep_symbolize_keys
  end

  def api_response
    JSON.parse(response.body, object_class: OpenStruct)
  end

  def mime_for(ext)
    case ext
      when :bmp, :png, :jpg, :jpeg, :JPEG, :gif, :BMP, :JPG, :PNG, :GIF then "image/#{ext.downcase}"
      when :pdf, :zip, :PDF, :ZIP then "application/#{ext.downcase}"
      when :rar, :RAR then "application/x-rar-compressed"
      else raise "No fixture for #{ext.downcase} files"
    end
  end
  
  def bytes_for(ext)
    fixtures = RSpec.configuration.file_fixture_path
    filename = if ext == ext.upcase
      "simple_upper.#{ext}"
    else
      "simple.#{ext}"
    end
  
    path = Pathname.new(File.join(fixtures, filename))
    Base64.encode64(path.read).delete!("\n")
  end

  def jsonapi_attachment(seed_type, seed_id, ext = :jpg)
    {
      type: "attachments",
      relationships: {attached_to_seed: {data: {id: seed_id, type: seed_type}}},
      attributes: {
        document: "data:#{mime_for(ext)};base64,#{bytes_for(ext)}",
        document_file_name: "áñçfile微信图片.#{ext}",
        document_content_type: mime_for(ext)
      }
    }
  end

  def jsonapi_base64_attachment(seed_type, seed_id, base64, ext = :jpg)
    {
      type: "attachments",
      relationships: {attached_to_seed: {data: {id: seed_id, type: seed_type}}},
      attributes: {
        document: "data:#{mime_for(ext)};base64,#{base64}",
        document_file_name: "from_base_64.#{ext}",
        document_content_type: mime_for(ext)
      }
    }
  end
end

RSpec.configuration.include RequestHelpers, type: :request
RSpec.configuration.include RequestHelpers, type: :feature

module LoggingHelpers
  def assert_logging(entity, verb, expected_count)
    EventLog.where(entity: entity, verb_id: EventLogKind.send(verb).id).count.should == expected_count
  end
end
RSpec.configuration.include LoggingHelpers, type: :model
