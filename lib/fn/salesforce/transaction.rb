module Fn
  module Salesforce

    class Transaction

      attr_reader :client, :plan, :failed, :actual

      def initialize(client, plan)
        @client = client
        @plan = plan
        @actual = []
        @failed = false
      end

      def execute
        @actual = plan.inject([]) { |results, operation|
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
        case operation.action
        when :create
          $stderr.puts "Creating #{operation.s_object}: #{ operation.properties }"
          id = client.create!( operation.s_object, operation.properties.dup )
          operation.properties.merge!( {"Id" => id} )
        when :update
          $stderr.puts "Finding #{operation.s_object}: #{ operation.lookup_with }"
          object = client.find(
            operation.s_object,
            *operation.lookup_with.invert.to_a.flatten
          ) 
          $stderr.puts "Found #{operation.s_object}(#{object.Id})"
          operation.properties.merge!( {"Id" => object.Id} )

          $stderr.puts "Updating #{operation.s_object}: #{ operation.properties }"
          client.update!( operation.s_object, operation.properties )

        when :upsert #TODO
          raise NotImplementedError
          # client.upsert!
        end

        operation
      end
    end
    
  end
  
end
