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

  describe 'preparing a child object' do

    let(:schema) { 
      JSON.parse(
        File.read('./spec/fixtures/nested_objects/test.schema.json')
      ) 
    }

    it "sets the sObject based on the relationship" do
      prepared_object = factory.create('my__Custom_Relationship__r', {
        "foo" => "bar"
      }, {})

      expect(prepared_object["sObject"]).to eql "my__Custom_Object__c"

    end

    it "adds the foreign key based on the relationship" do
      prepared_object = factory.create('my__Custom_Relationship__r', {
        "foo" => "bar"
      }, 10)

      expect(prepared_object["properties"]).to eql({
        "foo" => "bar",
        "vera__Test_Event__c" => {"$ref" => "/10/properties/Id"}
      })

    end
    
  end

end

