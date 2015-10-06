require 'spec_helper'

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

  context 'update' do

    let(:attributes) { JSON.parse(%Q{
      {
        "sObject": "my__ChildObject__c",
        "properties": {
          "my__Custom_Reference__c": { "$ref": "/1/properties/Id" }
        },
        "action": "update",
        "lookupWith": { "firstName": "Ile" }
      }
    }) }

    context '#action' do
      subject { operation.action }
      it { is_expected.to eql :update }
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

  context '#replace_refs', skip: "TODO" do
    it "replaces $ref properties based on the data provided"
    
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

