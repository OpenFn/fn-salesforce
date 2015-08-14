require 'hashie'

class Fn::Salesforce::Options

  def initialize(attributes)
    @attributes = attributes
  end


  def credentials
    return @credentials if @credentials

    credentials = JSON.parse(File.read(@attributes[:credentials]))
    @credentials = Hashie::Mash.new( {
      username:       credentials["username"],
      password:       credentials["password"],
      security_token: credentials["token"],
      client_id:      credentials["key"],
      client_secret:  credentials["secret"],
      host:           credentials["host"]
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
