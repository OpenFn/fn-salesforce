require 'virtus'

class Fn::Salesforce::Object
  include Virtus.model(:finalize => false)
end

class Fn::Salesforce::Object
  attribute :sobject, String
  attribute :parent, Fn::Salesforce::Object
  attribute :properties, Hash

end

Virtus.finalize
