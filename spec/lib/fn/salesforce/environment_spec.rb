require 'spec_helper'

describe Fn::Salesforce::Environment do

  let(:logger) { double("Logger instance", :level= => nil) }
  let(:options) { double("Options instance", target: "ObjectTarget") }

  it "sets up the logger" do
    expect(Logger).to receive(:new).with(STDERR).
      and_return logger

    expect(logger).to receive(:info).with("testing")

    described_class.new({}) do
      logger.info "testing"
    end
  end

  it "sets up an options object" do

    expect(Fn::Salesforce::Options).to receive(:new).with({foo: "bar"}).
      and_return options

    actual = nil
    described_class.new({foo: "bar"}) do
      actual = target
    end

    expect(actual).to eql "ObjectTarget"
  end
  
end
