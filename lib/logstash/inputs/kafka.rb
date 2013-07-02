require "logstash/inputs/base"
require "logstash/namespace"
require 'kafka'

# Read events through Kafka.
#
class LogStash::Inputs::Kafka < LogStash::Inputs::Base
  class Interrupted < StandardError; end
  config_name "kafka"
  plugin_status "beta"

  # The address to connect to.
  config :host, :validate => :string, :default => "0.0.0.0"

  # The port to connect to.
  config :port, :validate => :number, :required => true, :default => 9092

  config :topic, :validate => :string, :default => "logging"

  public
  def register
    @consumer = Kafka::Consumer.new(:topic => @topic, :host => @host, :port => @port)
  end # def register

  public
  def run(output_queue)
    @consumer.loop do |messages|
      messages.each do |msg|
        e = to_event(msg.payload, "kafka")
        output_queue << e
      end
    end
    finished
  end # def run

end # class LogStash::Inputs::Kafka  
