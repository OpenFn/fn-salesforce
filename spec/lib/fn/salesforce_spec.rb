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
        allow(Fn::Salesforce::Transaction).to receive(:new).and_return(transaction)
        push
      end

      let(:client) { double("Client") }
      let(:plan) { double("Plan") }
      let(:transaction) { double("Transaction", execute: true) }

      context "coerces the message to a Plan" do
        subject { Fn::Salesforce::Plan }
        it("creates a Plan") { is_expected.to have_received(:new).with(message) }
      end

      context "sets up the Restforce client" do
        subject { Restforce }
        it { is_expected.to have_received(:new).with(credentials) }
      end

      context 'sets up the Transaction' do
        subject { Fn::Salesforce::Transaction }
        it { is_expected.to have_received(:new).with(client, plan) }
      end

      context 'executes the transaction' do
        subject { transaction }
        it { is_expected.to have_received(:execute) }
        
      end
      
    end

    context 'on transaction failure', skip: "TODO" do
      it "creates a Rollback plan"
      it "executes the Rollback plan"
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
