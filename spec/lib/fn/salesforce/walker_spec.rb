require 'spec_helper'
require 'json'

describe Fn::Salesforce::Walker do

  describe ".parse" do
    it "calls the block for each child in the tree" do

      payload = JSON.load(File.open('spec/fixtures/nested_objects.json','r'))

      objects = []

      Fn::Salesforce::Walker.parse(payload) do |object|
        objects << object
        object
      end

      expect(objects.length).to eql(3)
    end

    # it ""
  end

end

