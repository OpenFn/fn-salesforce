require 'spec_helper'

describe Fn::Salesforce::Transaction do

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

  context '#execute' do

    before { allow(described_class).to receive(:perform) { |o,c| o } }

    let(:client) { double("Client") }
    let(:first_operation) { spy("Operation#1") }
    let(:second_operation) { spy("Operation#2") }
    let(:third_operation) { spy("Operation#3") }
    let(:plan) { [first_operation, second_operation, third_operation] }

    context 'dispatches each operation' do

      before :each do
        described_class.new(client, plan).execute
      end

      subject { described_class }
      it { is_expected.to have_received(:perform).with(first_operation,client) }
    end

    it 'replaces $ref' do
      
      expect(first_operation).to receive(:replace_refs).
        with([])
      expect(second_operation).to receive(:replace_refs).
        with([first_operation])
      expect(third_operation).to receive(:replace_refs).
        with([first_operation,second_operation])

      described_class.new(client, plan).execute

    end

    context 'when errors occur' do

      before { allow(described_class).to receive(:perform) { |o,c|
        if o == second_operation
          raise Exception, "Operation bums this test suite out." 
        end
        o
      } }

      let(:transaction) { described_class.new(client, plan) }
      before { transaction.execute }

      context '#failed' do
        subject { transaction.failed }
        it { is_expected.to be true }
      end

      context '#actual' do
        subject { transaction.actual.count }
        it { is_expected.to eql 1 }
      end
      
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

        let(:restforce_object) { spy("Account Object", Id: '4567') }
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

        it("merges in the located Id and calls #update!") {
          is_expected.to have_received(:update!).
            with('Account',{ "Name" => "Foobar", "Id" => "4567" } ) 
        }

      end
    end

    context 'after handling' do

      let(:operation) { Fn::Salesforce::Operation.new }
      subject { dispatcher }

      it { is_expected.to eql operation }
      
    end

  end
end
