# frozen_string_literal: true

require "ffi-gdal"
require "gdal"
require "gdal/utils"

RSpec.describe GDAL::Utils::TranslateOptions do
  context "when no options are provided" do
    it "returns a new instance of TranslateOptions" do
      subject { described_class.new }

      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(FFI::AutoPointer)
      expect(subject.c_pointer.null?).to be(false)
    end
  end

  context "when options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-unscale"] }

    it "returns a new instance of TranslateOptions with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(FFI::AutoPointer)
      expect(subject.c_pointer.null?).to be(false)
    end
  end

  context "when incorrect options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-unscale123"] }

    it "raises exception" do
      expect { subject }.to raise_exception(
        GDAL::UnsupportedOperation, "Unknown option name '-unscale123'"
      )
    end
  end
end
