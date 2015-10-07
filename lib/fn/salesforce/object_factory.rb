# ObjectFactory
# =============
#
# Factory class to help reconcile source data and the target schema.
# 
# By providing a JSON schema, that describes the relationships between 
# objects when traversing the message structure, we can prepare an object
# for sending.

require 'jsonpath'

class Fn::Salesforce::ObjectFactory

  attr_reader :schema
  def initialize(schema)
    raise ArgumentError, "Schema must be a hash." unless schema.is_a? Hash
    @schema = schema
  end

  def create(key, properties, parent=nil)
   
    [
      ->(obj) {
        { "properties" => properties }
      },
      ->(obj) {
        { "action" => "create" }
      },
      ->(obj) {
        { "sObject" => sobject_for(key) || key }
      },
      ->(obj) {
        return {} unless parent
        {
          "properties" => obj["properties"].merge(
            Hash[ foreign_key_for(key), {"$ref" => "/#{parent}/Id"} ]
          )
        }
      },
      ->(obj) { 
        return {} unless lookup_key = lookup_key_for(key)
        {
          "action" => "update",
          "lookupWith" => Hash[lookup_key, obj["properties"][lookup_key]],
          "properties" => obj["properties"].select { |k| k != lookup_key } 
        }
      }
    ].reduce({}) { |memo,op| memo.merge op[memo] }
  end

  def sobject_for(key)
    JsonPath.on(schema,"..properties.#{key}.sObject").first
  end

  def lookup_key_for(key)
    JsonPath.on(schema,"..properties.#{key}.lookupKey").first
  end

  def foreign_key_for(relationship_key)
    JsonPath.on(schema,"..properties.#{relationship_key}.foreignKey").first
  end
end
