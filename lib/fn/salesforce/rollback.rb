module Fn
  module Salesforce
    class Rollback < SimpleDelegator

      def initialize(plan)
        super(
          plan.map { |operation|
            operation.dup
          }.map { |operation| UndoFactory.coerce(operation) }
        )
      end

    end

    class UndoFactory
      def self.coerce(operation)
        case operation.action
        when :create
          operation["action"] = "delete"  
        when :update
          operation["properties"] = operation.previous_properties
        end

        operation
      end
    end

  end
end
