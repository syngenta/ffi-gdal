# frozen_string_literal: true

require "gdal/driver"
require "gdal/extensions/raster_band/extensions"

RSpec.describe "GDAL::RasterBand::Extensions" do
  let(:driver) { GDAL::Driver.by_name("MEM") }
  let(:dataset_byte) { driver.create_dataset("test", 15, 25, data_type: :GDT_Byte) }
  subject(:raster_band) { dataset_byte.raster_band(1) }

  describe "#to_a" do
    subject { raster_band.to_a }
    it { is_expected.to eq(Array.new(25, Array.new(15, 0))) }
  end

  describe "#to_na" do
    context "no conversion" do
      subject { raster_band.to_na }
      it { is_expected.to eq(Numo::UInt8.zeros(25, 15)) }
    end

    context "convert to Int16" do
      subject { raster_band.to_na(:GDT_Int16) }
      it { is_expected.to eq(Numo::Int16.zeros(25, 15)) }
    end

    context "convert to UInt16" do
      subject { raster_band.to_na(:GDT_UInt16) }
      it { is_expected.to eq(Numo::UInt16.zeros(25, 15)) }
    end

    context "convert to Int32" do
      subject { raster_band.to_na(:GDT_Int32) }
      it { is_expected.to eq(Numo::Int32.zeros(25, 15)) }
    end

    context "convert to UInt32" do
      subject { raster_band.to_na(:GDT_UInt32) }
      it { is_expected.to eq(Numo::UInt32.zeros(25, 15)) }
    end

    context "convert to Float32" do
      subject { raster_band.to_na(:GDT_Float32) }
      it { is_expected.to eq(Numo::SFloat.zeros(25, 15)) }
    end

    context "convert to Float64" do
      subject { raster_band.to_na(:GDT_Float64) }
      it { is_expected.to eq(Numo::DFloat.zeros(25, 15)) }
    end

    context "convert to CInt16" do
      subject { raster_band.to_na(:GDT_CInt16) }
      it { is_expected.to eq(Numo::SComplex.zeros(25, 15)) }
    end

    context "convert to CInt32" do
      subject { raster_band.to_na(:GDT_CInt32) }
      it { is_expected.to eq(Numo::SComplex.zeros(25, 15)) }
    end

    context "convert to CFloat32" do
      subject { raster_band.to_na(:GDT_CFloat32) }
      it { is_expected.to eq(Numo::SComplex.zeros(25, 15)) }
    end

    context "convert to CFloat64" do
      subject { raster_band.to_na(:GDT_CFloat64) }
      it { is_expected.to eq(Numo::DComplex.zeros(25, 15)) }
    end
  end
end
