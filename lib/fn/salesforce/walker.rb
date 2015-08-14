# Payload Tree Walker
# ===================
#
# Object Emitter for JSON payloads.
class Fn::Salesforce::Walker

  # Parse
  # -----
  #
  # ```ruby
  # counter = 0
  # parse(tree) do |key,properties|
  #   puts key
  #   puts properties
  #
  #   # The return result is passed back to the caller,
  #   # this way we can pass down the resulting `id` after the parent
  #   # object has been created.
  #   counter+= 1
  # end
  # ```

  def self.parse(tree, parent=nil, &block)
    tree.each { |obj,properties|
      # We assume all properties that belong to this object are not arrays.
      immediate_properties = properties.select { |k,v| !v.is_a?(Array) }

      # Without the child objects present, we send it out for processing.
      # Grab the result and carry on.
      result = block.call(obj, immediate_properties, parent)

      children = properties.select { |k,v| v.is_a?(Array) } \
        # We map out the array of child objects to single key/value hashes.
        .collect { |k,v| v.map { |v| {k => v} } }.flatten \
        # And send them off individually for processing.
        .each { |child|
          # The handle to the direct parent's result is made available.
          parse(child, result, &block)
        }
    }
  end

end
