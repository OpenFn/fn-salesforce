require 'hashie'

class Fn::Salesforce::Options

  def initialize(attributes)
    @attributes = attributes
  end


  def credentials
    return @credentials if @credentials

    if @attributes[:credentials].is_a? String
      attributes = JSON.parse(File.read(@attributes[:credentials]))
    else 
      attributes = @attributes[:credentials]
    end

    @credentials = Hashie::Mash.new( {
      username:       attributes["username"],
      password:       attributes["password"],
      security_token: attributes["token"],
      client_id:      attributes["key"],
      client_secret:  attributes["secret"],
      host:           attributes["host"]
    } ).to_hash(symbolize_keys: true)
  end

  def schema
    return @schema if @schema

    @schema = JSON.parse(File.read(@attributes[:schema]))
  end

  def message
    return @message if @message

    @message = JSON.parse(File.read(@attributes[:message]))
  end

  def plan
    return @plan if @plan

    @plan = JSON.parse(File.read(@attributes[:plan]))
  end

  def target
    @attributes[:target]
  end

  def format
    @attributes[:format]
  end
  
end
