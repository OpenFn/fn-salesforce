module Fn
  module Salesforce

    class Transaction

      attr_reader :client, :plan, :failed, :result
      attr_accessor :logger

      def initialize(client, plan, logger: Logger.new(STDOUT))
        @logger = logger
        @client = client
        @plan = plan
        @result = []
        @failed = false
      end

      def execute
        @result = plan.inject([]) { |results, operation|
          begin
            operation.replace_refs(results)
            results << perform(operation)
          rescue Exception => e
            logger.error "Transaction failed at ##{plan.index(operation)}"
            logger.error "Error message: #{e.message}"
            @failed = true
            break results
          end
          results
        }
      end


      def rollback!
        Rollback.new(result).each { |operation| perform(operation) }
      end

      private

      def perform(operation)
        case operation.action

        when :create
          logger.info "Creating #{operation.s_object}: #{ operation.properties.to_hash }"
          id = client.create!( operation.s_object, operation.properties.dup )
          operation.merge!( {"Id" => id} )
        when :update
          logger.info "Finding #{operation.s_object}: #{ operation.lookup_with.to_hash }"
          object = client.find(
            operation.s_object,
            *operation.lookup_with.invert.to_a.flatten
          ) 

          logger.info "Found #{operation.s_object}(#{object.Id})"
          # Keep the Id we get back from the find operation, we
          # use this for updating the object, and for rolling back if needed.
          operation.merge!( {"Id" => object.Id} )

          # Slice off the fields we are about to change, and put them on
          # 'previousProperties'.
          operation.previousProperties = object.select { |key, value|
            operation.properties.keys.include?(key)
          }
          logger.info "Updating #{operation.s_object}: #{ operation.properties.to_hash }"

          client.update!(
            operation.s_object,
            Hash["Id", operation["Id"]].merge( operation.properties )
          )

        when :delete
          logger.info "Deleting #{operation.s_object}(#{operation.Id})"
          client.destroy!(operation.sObject, operation.Id)

        when :upsert
          logger.info "Upserting #{operation.s_object}(#{operation.externalID})"
          client.upsert!(operation.sObject, operation.externalID, operation.properties)
        else
          logger.warn "Warning: No action found for #{operation.inspect}. Skipping."
        end

        operation
      end

    end

  end


end
