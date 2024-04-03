# frozen_string_literal: true

require "ffi-gdal"
require "gdal"
require "gdal/utils"
require "securerandom"

RSpec.describe GDAL::Utils do
  let(:tiff) do
    path = "../../../spec/support/images/osgeo/geotiff/GeogToWGS84GeoKey/GeogToWGS84GeoKey5.tif"
    File.expand_path(path, __dir__)
  end

  let(:dataset) { GDAL::Dataset.open(tiff, "r") }
  after { dataset.close }

  describe ".info" do
    context "when no options are provided" do
      it "returns GDALInfo text" do
        expect(described_class.info(dataset: dataset)).to include("Driver: GTiff/GeoTIFF")
      end
    end

    context "when options are provided" do
      it "returns GDALInfo text with options applied" do
        options = GDAL::Utils::InfoOptions.new(options: ["-json"])
        parsed_result = JSON.parse(described_class.info(dataset: dataset, options: options))
        expect(parsed_result).to include(
          {
            "driverShortName" => "GTiff",
            "driverLongName" => "GeoTIFF",
            "size" => [101, 101]
          }
        )
      end
    end
  end

  describe ".translate" do
    context "when no options are provided" do
      it "returns new dataset" do
        new_dataset_path = "/vsimem/test-#{SecureRandom.uuid}.tif"
        new_dataset = described_class.translate(src_dataset: dataset, dst_dataset_path: new_dataset_path)

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils.info(dataset: new_dataset)).not_to include("COMPRESSION=DEFLATE")

        new_dataset.close
      end

      it "returns new dataset in block" do
        new_dataset_path = "/vsimem/test-#{SecureRandom.uuid}.tif"

        described_class.translate(src_dataset: dataset, dst_dataset_path: new_dataset_path) do |new_dataset|
          expect(new_dataset).to be_a(GDAL::Dataset)
        end
      end
    end

    context "when options are provided" do
      it "returns new dataset with options applied" do
        options = GDAL::Utils::TranslateOptions.new(options: ["-co", "COMPRESS=DEFLATE"])
        new_dataset_path = "/vsimem/test-#{SecureRandom.uuid}.tif"

        new_dataset = described_class.translate(
          src_dataset: dataset, dst_dataset_path: new_dataset_path, options: options
        )

        expect(new_dataset).to be_a(GDAL::Dataset)
        expect(GDAL::Utils.info(dataset: new_dataset)).to include("COMPRESSION=DEFLATE")

        new_dataset.close
      end
    end

    context "when operation fails" do
      it "raises exception" do
        options = GDAL::Utils::TranslateOptions.new(options: ["-b", "100"])
        new_dataset_path = "/vsimem/test-#{SecureRandom.uuid}.tif"

        expect do
          described_class.translate(src_dataset: dataset, dst_dataset_path: new_dataset_path, options: options)
        end.to raise_exception(
          GDAL::Error, "Band 100 requested, but only bands 1 to 1 available."
        )
      end
    end
  end
end
