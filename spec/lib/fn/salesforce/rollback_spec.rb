require 'spec_helper'

describe Fn::Salesforce::Rollback do

  context '#new' do

    let(:first_operation) { double("Operation") }
    let(:second_operation) { double("Operation") }
    let(:plan) { [first_operation, second_operation] }

    before { allow(Fn::Salesforce::UndoFactory).to receive(:coerce) { |o| o } }

    let!(:rollback) { described_class.new(plan) }

    it 'dups the operations' do
      expect(rollback[0]).to_not equal first_operation
      expect(rollback[1]).to_not equal second_operation
    end

    it 'inverts the operation using UndoFactory' do
      expect(Fn::Salesforce::UndoFactory).to have_received(:coerce).twice
    end
    
  end
  
end

describe Fn::Salesforce::UndoFactory do

  describe '.coerce' do

    let(:operation) { Fn::Salesforce::Operation.new(attributes) }
    let!(:coercion) { described_class.coerce(operation) }

    context 'create -> delete' do
      let(:attributes) { {
        "sObject" => "my__ObjectName__c", "properties" => { "Name" => "Belthazar" }
      } }

      subject { coercion.action }
      it { is_expected.to eql :delete }
      
    end

    context 'update' do
      let(:attributes) { {
        "sObject"=>"my__ChildObject__c",
        "Id"=>"1234",
        "properties"=>{
          "my__Custom_Reference__c"=>"4567"
        }, 
        "action"=>"update",
        "previousProperties" => {
          "my__Custom_Reference__c"=>"7891"
        },
        "lookupWith"=>{"firstName"=>"Ile"}
      } }


      it 'stays as an update' do
        expect(coercion.action).to eql :update
      end

      it 'replaces properties with previousProperties' do
        expect(coercion.properties).to eql coercion.previous_properties
      end
      
    end
    
  end
  
end
