require 'spec_helper'

describe Fn::Salesforce::ObjectFactory do

  describe ".new" do

    subject { described_class.new(schema).schema }

    context 'with a schema' do
      let(:schema) { {} }
      it "returns factory instance with the schema attached" do
        expect(subject).to eql schema
      end
    end

    context 'without a schema' do
      let(:schema) { nil }
      it { 
        expect( -> { subject } ).to(
          raise_error(ArgumentError, "Schema must be a hash.")
        )
      }
    end

  end

  let(:factory) { described_class.new(schema) }

  describe "#create" do
    let(:schema) { {} }

    let(:key) { 'my__Custom_Object__c' }
    let(:properties) { {'name' => 'Fred'} }

    subject { factory.create(key,properties) }

    it { expect(subject["sObject"]).to eql('my__Custom_Object__c') }

    it { expect(subject["properties"][ 'name' ]).to eql( 'Fred' ) }

  end

  describe 'sobject_for' do

    let(:schema) { 
      JSON.parse(
        File.read('./spec/fixtures/nested_objects/test.schema.json')
      ) 
    }

    subject { factory.sobject_for(key) }

    context 'when querying a relationship' do
      let(:key) { 'my__Custom_Relationship__r' }

      it { expect(subject).to eql('my__Custom_Object__c') }
    end

  end

  describe "preparing" do
    
    let(:schema) { 
      JSON.parse( %{
          {
            "title" : "Test Object",
            "properties" : {
              "my__Custom_Relationship__r" : {
                "type" : "array",
                "foreignKey" : "vera__Test_Event__c",
                "sObject" : "my__Custom_Object__c"
              },
              "my__Existing_Objects__r" : {
                "type" : "array",
                "foreignKey" : "vera__Test_Event__c",
                "sObject" : "my__Custom_Object__c",
                "lookupKey" : "foo"
              }
            },
            "type" : "object",
            "$schema" : "http://json-schema.org/draft-04/schema#"
          }
      }) 
    }

    subject { prepared_object }

    describe 'a child object' do

      let(:prepared_object) { 
        factory.create('my__Custom_Relationship__r', { "foo" => "bar" }, 10)
      }

      it { is_expected.to eql( {
        "sObject" => "my__Custom_Object__c",
        "properties" => {
          "foo" => "bar",
          "vera__Test_Event__c" => {"$ref"=>"/10/properties/Id"}
        }
      } )}

    end

    describe 'preparing an object update' do

      let(:prepared_object) { 
        factory.create('my__Existing_Objects__r', { "foo" => "bar" }, 10)
      }

      it { is_expected.to eql( {
        "sObject" => "my__Custom_Object__c",
        "lookupWith" => {
          "foo" => "bar"
        },
        "method" => "update",
        "properties" => {
          "vera__Test_Event__c" => {"$ref"=>"/10/properties/Id"}
        }
      } )}

    end
  end


end

