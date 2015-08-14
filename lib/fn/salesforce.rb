require "json"
require "fn/salesforce/version"
require "fn/salesforce/environment"
require "fn/salesforce/options"
require "fn/salesforce/object"
require "fn/salesforce/object_factory"
require "fn/salesforce/walker"
require "restforce"
require "hana"

module Fn
  module Salesforce

    # Push
    # ----
    # Takes a prepared payload, and sends it to Salesforce.
    def self.push(credentials, message)

      client = Restforce.new(credentials)
      message.
        inject([]) { |plan,obj| 

        begin
          obj["properties"].merge! obj["properties"].
            map { |k,v| 
            if v.is_a?(Hash) && v["$ref"]
              v = Hana::Pointer.new(v["$ref"]).eval(plan)
            end
            [k,v]
          }.
          map { |i| Hash[*i] }.inject(&:merge)

          $stderr.puts "Creating #{obj["sObject"]}: #{ obj["properties"] }"
          id = client.create!(obj["sObject"], obj["properties"])

          obj["properties"]["Id"] = id
          plan.push obj

        rescue Exception => e
          $stderr.puts e
          if plan.any?
            $stderr.puts "Rolling back previous objects"
            plan.each { |obj| 
              id = obj["properties"]["Id"]
              object = obj["sObject"]
              $stderr.puts "Deleting #{object}##{id}"
              client.destroy(object, id) 
            }
          end
          break
        end

      }
    end

    # Prepare
    # -------
    # Unpack the message, and return a data object ready for sending.
    def self.prepare(schema, message)
      factory = Fn::Salesforce::ObjectFactory.new(schema)

      raw_payload = []
      Walker.parse(message) do |key, properties, parent|
        obj = factory.create(key, properties, parent)
        $stderr.puts obj
        raw_payload << obj

        raw_payload.index obj
      end

      raw_payload

    end

    # Describe
    # --------
    def self.describe(credentials, target)

     client = Restforce.new(credentials)
     client.describe(target)

    end
  end
end
