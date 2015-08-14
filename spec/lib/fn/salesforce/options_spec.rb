require 'spec_helper'

describe Fn::Salesforce::Options do

  describe "#credentials" do
    subject { 
      described_class.new({
        credentials: 'spec/fixtures/credentials.json'
      }).credentials 
    }

    it "returns credentials when provided a file path" do
      expect(subject[:username]).to eql "my@address.net"
      expect(subject[:client_id]).to eql "keykey"
    end
    
  end

  describe "#target" do
    subject { 
      described_class.new({
        target: 'Vera__Custom_Object__c'
      }).target
    }

    it { is_expected.to eql "Vera__Custom_Object__c" }
  end
  
end
