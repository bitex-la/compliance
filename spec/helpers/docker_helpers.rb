class DockerHelpers
  def self.port
    Settings.sqs.port
  end

  def self.ensure_elastic_mq_test_is_running
    unless find_running_by_port(port)
      puts "ElasticMQ server not found, running it first"

      config_path = Rails.root.join('docker/standalone/elasticmq.conf')
      `docker run -d -p #{port}:9324 -v #{config_path}:/opt/elasticmq.conf softwaremill/elasticmq-native`
      since = Time.now.to_i
      loop do
        begin
          Aws::SQS::Client.new(endpoint: "http://localhost:#{port}").list_queues
          break
        rescue
          if (Time.now.to_i - since) < 120
            puts 'Wait a moment for ElasticMQ...'
            sleep 10
            retry
          else
            puts 'Failed to run ElasticMQ server'
            raise
          end
        end
      end
    end
  end

  def self.find_running_by_port(port)
    result = `docker ps -f 'status=running' --format "{{.ID}} {{.Ports}}"`
    return nil if result.blank?

    if result =~ /(.*?) 0.0.0.0:#{port}->9324.*$/
      return $1
    end
  end
end
