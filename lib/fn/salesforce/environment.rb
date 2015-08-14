# Fn Salesforce Environment
# =========================
#
# Interface for performing operations, sets up the logger and provides
# access to configuration objects.
#
# Since using the tool via the CLI and API requires slightly different 
# handling for errors and feedback, this can be used to facilitate that.

require 'logger'
require 'forwardable'

# Fn::Salesforce::Environment.new({schema: "SCHEMA"}) do
#   begin
#     prepare(schema, payload) { |plan|
#       raise "hell"
#     }
#   rescue
#     logger.error "Hello"
#     exit(1)
#   end
# end

class Fn::Salesforce::Environment
  extend Forwardable
  def_delegators :@options, :credentials, :schema, :payload, :target, 
    :format, :message, :plan

  attr_reader :logger

  def initialize(options, &block)
    @options = Fn::Salesforce::Options.new(options)
    @logger = Logger.new(STDERR)
    @logger.level = Logger::DEBUG

    instance_eval &block
    
  end

  # ## Prepare
  # ```rb
  # prepare(schema, payload) { |plan|
  #   puts plan.inspect
  #   logger.info plan.inspect
  # }
  # ```

  def prepare(schema, payload, &block)
    yield Fn::Salesforce.prepare(schema, payload)
  end

  # ## Describe
  # ```rb
  # describe(credentials, target) { |description|
  #   pp description.inspect
  # }
  # ```

  def describe(credentials, target, &block)
    yield Fn::Salesforce.describe(credentials, target)
  end

  # ## Push
  # ```rb
  # push(credentials, plan) { |results|
  #   pp results
  # }
  # ```

  def push(credentials, plan, &block)
    yield Fn::Salesforce.push(credentials, plan)
  end

end

