require 'spec_helper'

describe Fn::Salesforce do

  describe "#push" do

    let(:message) {
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
            }
          },
          "action": "update",
          "lookupWith": { "firstName": "Ile" }
        }
      ]'
    }

    let(:credentials) { spy("Credentials") }
    let(:push) { Fn::Salesforce.push(credentials, message) }

    context 'setting up' do

      before :each do
        allow(Restforce).to receive(:new).and_return(client)
        allow(Fn::Salesforce::Plan).to receive(:new).and_return(plan)
        allow(Fn::Salesforce::Dispatcher).to receive(:new).and_return(dispatcher)
        push
      end

      let(:client) { double("Client") }
      let(:plan) { double("Plan") }
      let(:dispatcher) { double("Dispatcher", execute: true) }

      context "coerces the message to a Plan" do
        subject { Fn::Salesforce::Plan }
        it { is_expected.to have_received(:new).with(message) }
      end

      context "sets up the Restforce client" do
        subject { Restforce }
        it { is_expected.to have_received(:new).with(credentials) }
      end

      context 'sets up the Dispatcher' do
        subject { Fn::Salesforce::Dispatcher }
        it { is_expected.to have_received(:new).with(client, plan) }
      end

      context 'executes the dispatcher' do
        subject { dispatcher }
        it { is_expected.to have_received(:execute) }
        
      end
      
    end

    context 'when working' do
      context 'calls execute on the dispatcher' do
        before do
          allow(Fn::Salesforce::Dispatcher).to receive(:perform)
          push
        end

        subject { Fn::Salesforce::Dispatcher }
        it { is_expected.to have_received(:perform).exactly(4).times }
      end
      context 'it updates references', skip: "TODO"
    end

    context 'handling errors' do
      context 'it stops processing operations', skip: "TODO"
    end


    it "sends objects to Salesforce in order", skip: "DEPRECATED" do
      expect(Restforce).to receive(:new).and_return(client)
      expect(client).to receive(:create!).exactly(2).times
      expect(client).to receive(:update!).exactly(1).times
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

      expect(client).to receive(:upsert!).with(
        "my__ChildObject__c", 
        { "firstName" => "Ile" },
        { "my__Custom_Reference__c" => "67891" }
      )

      subject
    end

    pending "performs a rollback when an error is encountered" do
      expect(Restforce).to receive(:new).and_return(client)

      expect(client).to receive(:create!).with("my__ObjectName__c", {
        "Name" => "Belthazar"
      }).and_return "12345"

      expect(client).to receive(:create!).with("my__ChildObject__c", {
        "my__Custom_Reference__c" => "12345",
        "firstName" => "Stuart"
      }).and_return "67891"

      expect(client).to receive(:update!).with(
        "my__ChildObject__c", 
        { "firstName" => "Ile" },
        { "my__Custom_Reference__c" => "67891" }
      ).and_raise Exception

      expect(client).to receive(:destroy).with('my__ObjectName__c', '12345')
      expect(client).to receive(:destroy).with('my__ChildObject__c', '67891')

      subject
      
    end
  end

  describe "#prepare" do
    it "raises an error when not provided configuration" do
      expect( -> {
        Fn::Salesforce.prepare
      } ).to raise_error ArgumentError
    end

    context "parent-child dependencies" do

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
