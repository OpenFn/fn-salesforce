require 'spec_helper'
require 'pry-byebug'

describe Fn::Salesforce::Operation do

  let(:operation) { described_class.new(attributes) }

  context 'create' do

    let(:attributes) { {
      "sObject" => "my__ObjectName__c", "properties" => { "Name" => "Belthazar" }
    } }

    context '#action' do
      subject { operation.action }
      it { is_expected.to eql :create }
    end

    context '#s_object' do
      subject { operation.s_object }
      it { is_expected.to eql "my__ObjectName__c" }
    end

    context '#lookup_with' do
      subject { operation.lookup_with }
      it { is_expected.to eql( nil ) }
    end

    context '#properties' do
      subject { operation.properties }
      it { is_expected.to eql( { "Name" => "Belthazar" } ) }
    end

  end

  context 'upsert' do

    let(:attributes) { JSON.parse(%Q{
      {
        "sObject": "my__ChildObject__c",
        "properties": {
          "my__Custom_Reference__c": { "$ref": "/1/properties/Id" }
        },
        "action": "upsert",
        "lookupWith": { "firstName": "Ile" }
      }
    }) }

    context '#action' do
      subject { operation.action }
      it { is_expected.to eql :upsert }
    end

    context '#lookup_with' do
      subject { operation.lookup_with }
      it { is_expected.to eql( { "firstName" => "Ile" } ) }
    end

    context '#properties' do
      subject { operation.properties }
      it { is_expected.to eql( {
        "my__Custom_Reference__c" => { "$ref" => "/1/properties/Id" }
      } ) }
    end
  end

  context 'references' do

    subject { operation.references }

    let(:attributes) { {
      "sObject"=>"my__ChildObject__c",
      "properties"=>{"Name"=>"Foobar"}.merge(reference),
      "action"=>"upsert",
      "lookupWith"=>{"firstName"=>"Ile"}
    } }

    context 'when present' do
      let(:reference) { 
        { "my__Custom_Reference__c" => { "$ref" => "/1/properties/Id" } } 
      }
      it { is_expected.to_not be_empty }
      it { is_expected.to eql(reference) }
    end

    context 'when not present' do
      let(:reference) { {} }
      it { is_expected.to be_empty }
    end
    
  end

end

describe Fn::Salesforce::Dispatcher do


  context '#initialize' do

    let(:client) { double("Client") }
    let(:plan) { double("Plan") }
    let(:dispatcher) { described_class.new(client, plan) }
    context '#plan' do
      subject { dispatcher.plan }
      it { is_expected.to eql plan }
    end

    context '#client' do
      subject { dispatcher.client }
      it { is_expected.to eql client }
    end

    
  end

  context '.perform' do

    let!(:dispatcher) { described_class.perform(operation, client) }
    let(:client) { spy("Client") }

    context 'when handling' do

      subject { client }

      describe "a create operation" do
        let(:operation) { Fn::Salesforce::Operation.new({
          "sObject" => "Account",
          "properties" => { "Name" => "Foobar" }
        }) }

        it("creates a new object"){
          is_expected.to have_received(:create!).
          with("Account", "Name" => "Foobar")
        }

        context 'appends the Id' do
          let(:client) { spy("Client", create!: '1234') }
          subject { operation.properties["Id"] }
          it { is_expected.to eql('1234') }
        end
      end

      describe "an upsert operation", skip: "NOT IMPLEMENTED" do
        let(:operation) { Fn::Salesforce::Operation.new("action" => "upsert") }
        it { is_expected.to have_received(:upsert!) }
      end

      describe "an update operation" do

        let(:restforce_object) { spy("Account Object") }
        let(:client) { spy("Client", { find: restforce_object }) }
        let(:operation) { Fn::Salesforce::Operation.new({
          "action" => "update",
          "sObject" => "Account",
          "properties" => { "Name" => "Foobar" },
          "lookupWith" => { 'Some_External_Id_Field__c' => '1234' }
        }) }

        it("finds the particular object") {
          is_expected.to have_received(:find).
          with('Account', '1234', 'Some_External_Id_Field__c') 
        }

        context 'and updates it' do
          subject { restforce_object }

          it { is_expected.to have_received(:merge!).with({ "Name" => "Foobar" }) }
          it { is_expected.to have_received(:save!) }

        end

      end
    end

    context 'after handling' do

      let(:operation) { Fn::Salesforce::Operation.new }
      subject { dispatcher }

      it { is_expected.to eql operation }
      
    end

  end
end
