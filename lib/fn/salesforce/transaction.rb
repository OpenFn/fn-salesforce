module Fn
  module Salesforce

    class Transaction

      attr_reader :client, :plan, :failed, :result

      def initialize(client, plan)
        @client = client
        @plan = plan
        @result = []
        @failed = false
      end

      def execute
        @result = plan.inject([]) { |results, operation|
          begin
            operation.replace_refs(results)
            results << Transaction.perform(operation,client)
          rescue Exception => e
            $stderr.puts "Transaction failed at ##{plan.index(operation)}"
            @failed = true
            break results
          end
          results
        }
      end

      def self.perform(operation, client)
        puts operation.action.inspect
        case operation.action

        when :create
          $stderr.puts "Creating #{operation.s_object}: #{ operation.properties.to_hash }"
          id = client.create!( operation.s_object, operation.properties.dup )
          operation.merge!( {"Id" => id} )
        when :update
          $stderr.puts "Finding #{operation.s_object}: #{ operation.lookup_with.to_hash }"
          object = client.find(
            operation.s_object,
            *operation.lookup_with.invert.to_a.flatten
          ) 

          $stderr.puts "Found #{operation.s_object}(#{object.Id})"
          # Keep the Id we get back from the find operation, we
          # use this for updating the object, and for rolling back if needed.
          operation.merge!( {"Id" => object.Id} )

          # Slice off the fields we are about to change, and put them on
          # 'previousProperties'.
          operation.previousProperties = object.select { |key, value|
            operation.properties.keys.include?(key)
          }
          $stderr.puts "Updating #{operation.s_object}: #{ operation.properties.to_hash }"

          client.update!(
            operation.s_object,
            Hash["Id", operation["Id"]].merge( operation.properties )
          )

        when :delete
          $stderr.puts "Deleting #{operation.s_object}(#{operation.Id})"
          client.destroy!(operation.sObject, operation.Id)

        when :upsert #TODO
          raise NotImplementedError
          # client.upsert!
        else
          $stderr.puts "Warning: No action found for #{operation.inspect}. Skipping."
        end

        operation
      end

      def rollback!
        Rollback.new(result).each { |operation|
          Transaction.perform(operation, client)
        }
      end

    end

  end


end
