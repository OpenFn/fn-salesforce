require "json"
require "fn/salesforce/version"
require "fn/salesforce/environment"
require "fn/salesforce/options"
require "fn/salesforce/operation"
require "fn/salesforce/rollback"
require "fn/salesforce/transaction"
require "fn/salesforce/object_factory"
require "fn/salesforce/walker"
require "restforce"
require "hana"

module Fn
  module Salesforce

    # Push
    # ----
    # Takes a prepared payload, and sends it to Salesforce.
    def self.push(credentials, message, logger: Logger.new(STDOUT))

      client = Restforce.new(credentials)
      plan = Plan.new(message)

      transaction = Transaction.new(client, plan, logger: logger)

      transaction.execute

      transaction.rollback! if transaction.failed

      # Return true for success, false for failure.
      !transaction.failed

    end

    # Prepare
    # -------
    # Unpack the message, and return a data object ready for sending.
    def self.prepare(schema, message)
      factory = Fn::Salesforce::ObjectFactory.new(schema)

      raw_payload = []
      Walker.parse(message) do |key, properties, parent|
        obj = factory.create(key, properties, parent)
        $stderr.puts obj
        raw_payload << obj

        raw_payload.index obj
      end

      raw_payload

    end

    # Describe
    # --------
    def self.describe(credentials, target)

     client = Restforce.new(credentials)
     client.describe(target)

    end
  end
end
