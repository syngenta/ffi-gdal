# frozen_string_literal: true

require "ffi-gdal"
require "gdal"
require "gdal/utils"

RSpec.describe GDAL::Utils::InfoOptions do
  context "when no options are provided" do
    it "returns a new instance of InfoOptions" do
      subject { described_class.new }

      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(FFI::AutoPointer)
      expect(subject.c_pointer.null?).to be(false)
    end
  end

  context "when options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-json"] }

    it "returns a new instance of InfoOptions with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(FFI::AutoPointer)
      expect(subject.c_pointer.null?).to be(false)
    end
  end

  context "when incorrect options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-json123"] }

    it "raises exception" do
      expect { subject }.to raise_exception(
        GDAL::UnsupportedOperation, "Unknown option name '-json123'"
      )
    end
  end
end
