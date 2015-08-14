require 'pry-byebug'
module Fn::Salesforce
  class CLI
    class << self

      # TODO: Move options validation from bin to CLI class
      def push(opts,schema,file)
        begin
          payload = JSON.parse(File.read(file))
          schema = JSON.parse(File.read(schema))

          pp Fn::Salesforce.push({}, schema, payload)

        rescue => e
          logger = Logger.new(STDERR)
          logger.level = Logger::DEBUG
          logger.error e
          logger.debug e.backtrace.join("\n") if opts[:verbose]
        ensure
          exit(1)
        end

      end

      def prepare(opts)
        Environment.new(opts) do
          logger.debug "Preparing"

          prepare(schema, message) { |plan|
            puts JSON.pretty_generate plan
          }

        end

        exit(0)
      end

      def describe(opts)
        Environment.new(opts) do
          logger.debug "Describing: #{target}"
          logger.debug "Credentials:"
          logger.debug credentials

          describe(credentials, target) { |description|
            case format
            when 'raw'
              puts description
            when 'json'
              puts JSON.pretty_generate description
            end
          }

        end

        exit(0)
      end

      def push(opts)
        Environment.new(opts) do
          logger.debug "Pushing to Salesforce"
          logger.debug "Credentials:"
          logger.debug credentials

          push(credentials, plan) { |results|
            pp results
          }

        end

        exit(0)
      end

    end
  end
end
