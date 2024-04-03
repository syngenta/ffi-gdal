# frozen_string_literal: true

require "ffi-gdal"
require "gdal"
require "gdal/utils"

RSpec.describe GDAL::Utils::OptionsList do
  context "when no options are provided" do
    it "returns a new instance of OptionsList" do
      subject { described_class.new }

      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(FFI::AutoPointer)
      expect(subject.c_pointer.null?).to be(true)
    end
  end

  context "when options are provided" do
    subject { described_class.new(options: options) }

    let(:options) { ["-option1", "-option2"] }

    it "returns a new instance of OptionsList with options" do
      expect(subject).to be_a(described_class)
      expect(subject.c_pointer).to be_a(FFI::AutoPointer)
      expect(subject.c_pointer.null?).to be(false)
    end
  end
end
