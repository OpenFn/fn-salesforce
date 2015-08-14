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
    sobject = sobject_for(key) || key
    properties.merge! Hash[foreign_key_for(key), {"$ref" => "/#{parent}/properties/Id"}] if parent

    {
      "sObject" => sobject,
      "properties" => properties
    }
  end

  def sobject_for(key)
    JsonPath.on(schema,"..properties.#{key}.sObject").first
  end

  def foreign_key_for(relationship_key)
    JsonPath.on(schema,"..properties.#{relationship_key}.foreignKey").first
  end
end
