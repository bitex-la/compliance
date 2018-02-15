class JsonApi::Error
  attr_accessor :links, :status, :code, :title, :detail, :source, :meta

  def initialize(error_data = {})
    @links  = error_data[:links]
    @status = error_data[:status]
    @code   = error_data[:code]
    @title  = error_data[:title]
    @detail = error_data[:detail]
    @source = error_data[:source]
    @meta   = error_data[:meta]
  end
end