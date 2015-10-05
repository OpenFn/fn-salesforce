require 'virtus'
require 'delegate'

module Fn
  module Salesforce


    class Operation < SimpleDelegator
      def initialize(attrs={})
        super(attrs)
      end

      def action
        ( send( :[], "action" ) || :create ).to_sym
      end

      def s_object
        send :[], "sObject"
      end

      def lookup_with
        send :[], "lookupWith"
      end

      def properties
        ( send :[], "properties" ) || {}
      end

      def references
        properties.select { |k,v| 
          v.is_a? Hash
        }.select { |k,v|
          v.keys.any? { |key| key == "$ref" }
        }
      end
    end

    class Plan < SimpleDelegator
      def initialize(operations)
        super(operations.map { |op| Operation.new(op) })
      end
    end

    class Dispatcher

      attr_reader :client, :plan

      def initialize(client, plan)
        @client = client
        @plan = plan
      end

      def self.perform(operation, client)
        case operation.action
        when :create
          id = client.create!( operation.s_object, operation.properties.dup )
          operation.properties.merge!( {"Id" => id} )
        when :update
          object = client.find(
            operation.s_object,
            *operation.lookup_with.invert.to_a.flatten
          ) 

          object.merge! operation.properties
          object.save!
        when :upsert
          client.upsert!
        end

        operation
      end
    end
  end
end
