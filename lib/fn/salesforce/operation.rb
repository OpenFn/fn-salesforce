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

      def previous_properties
        ( send :[], "previousProperties" ) || {}
      end

      def references
        properties.select { |k,v| 
          v.is_a? Hash
        }.select { |k,v|
          v.keys.any? { |key| key == "$ref" }
        }
      end

      def replace_refs(data)
        properties.merge! properties.
            map { |k,v| 
            if v.is_a?(Hash) && v["$ref"]
              v = Hana::Pointer.new(v["$ref"]).eval(data)
            end
            [k,v]
          }.
          map { |i| Hash[*i] }.inject(&:merge)
      end
    end

    class Plan < SimpleDelegator
      def initialize(operations)
        super(operations.map { |op| Operation.new(op) })
      end
    end

  end
end
