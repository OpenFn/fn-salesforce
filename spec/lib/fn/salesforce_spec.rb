require 'spec_helper'

describe Fn::Salesforce do

  describe "#push" do

    let(:prepared_payload) {
      JSON.parse '[
        {
          "sObject": "my__ObjectName__c",
          "properties": {
            "Name": "Belthazar"
          }
        },
        {
          "sObject": "my__ChildObject__c",
          "properties": {
            "firstName" : "Stuart",
            "my__Custom_Reference__c": {
              "$ref": "/0/properties/Id"
            }
          }
        },
        {
          "sObject": "my__ChildObject__c",
          "properties": {
            "my__Custom_Reference__c": {
              "$ref": "/1/properties/Id"
            },
            "firstName" : "Ile"
          }
        }
      ]'
    }

    subject { Fn::Salesforce.push({}, prepared_payload) }

    let(:client) { double("Restforce client") }

    it "sends objects to Salesforce in order" do
      expect(Restforce).to receive(:new).and_return(client)
      expect(client).to receive(:create!).exactly(3).times
      subject
    end

    it "populates $refs when encountered" do
      expect(Restforce).to receive(:new).and_return(client)

      expect(client).to receive(:create!).with("my__ObjectName__c", {
        "Name" => "Belthazar"
      }).and_return "12345"

      expect(client).to receive(:create!).with("my__ChildObject__c", {
        "my__Custom_Reference__c" => "12345",
        "firstName" => "Stuart"
      }).and_return "67891"

      expect(client).to receive(:create!).with("my__ChildObject__c", {
        "my__Custom_Reference__c" => "67891",
        "firstName" => "Ile"
      })

      subject
    end

    it "performs a rollback when an error is encountered" do
      expect(Restforce).to receive(:new).and_return(client)

      expect(client).to receive(:create!).with("my__ObjectName__c", {
        "Name" => "Belthazar"
      }).and_return "12345"

      expect(client).to receive(:create!).with("my__ChildObject__c", {
        "my__Custom_Reference__c" => "12345",
        "firstName" => "Stuart"
      }).and_return "67891"

      expect(client).to receive(:create!).with("my__ChildObject__c", {
        "my__Custom_Reference__c" => "67891",
        "firstName" => "Ile"
      }).and_raise Exception

      expect(client).to receive(:destroy).with('my__ObjectName__c', '12345')
      expect(client).to receive(:destroy).with('my__ChildObject__c', '67891')

      subject
      
    end
  end

  describe "#prepare" do
    it "raises an error when not provided configuration" do
      expect( -> {
        Fn::Salesforce.push
      } ).to raise_error ArgumentError
    end

  end

  describe "#describe" do
    it "raises an error when not provided configuration" do
      expect( -> {
        Fn::Salesforce.describe
      } ).to raise_error ArgumentError
    end

  end

end
