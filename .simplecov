SimpleCov.start 'rails' do
  # Disambiguates individual test runs with CIRCLE_NODE_INDEX
  command_name "Job #{ENV['CIRCLE_NODE_INDEX']}" if ENV['CIRCLE_NODE_INDEX']

  # If running test in CI, generate just .json result, then we can join them later
  # else, generate the full HTML report
  if ENV['IN_CIRCLE']
    formatter SimpleCov::Formatter::SimpleFormatter
  else
    formatter SimpleCov::Formatter::MultiFormatter.new(
      [
        SimpleCov::Formatter::SimpleFormatter,
        SimpleCov::Formatter::HTMLFormatter
      ]
    )
  end

  track_files "**/*.rb"
  enable_coverage :branch

  {
    "Admin" => "app/admin",
    "Serializers" => "app/serializers",
    "Services" => "app/services"
  }.each { |k, v| add_group k, v }

end
