# frozen_string_literal: true

require_relative "../gdal"
require_relative "utils/info_options"
require_relative "utils/translate_options"

module GDAL
  module Utils
    def self.info(dataset:, options: InfoOptions.new)
      string, str_pointer = FFI::GDAL::Utils.GDALInfo(dataset.c_pointer, options.c_pointer)

      string
    ensure
      # Returned string pointer must be freed with CPLFree()
      FFI::CPL::VSI.VSIFree(str_pointer)
    end

    def self.translate(src_dataset:, dst_dataset_path:, options: TranslateOptions.new, &block)
      GDAL::Dataset.open(
        FFI::GDAL::Utils.GDALTranslate(dst_dataset_path, src_dataset.c_pointer, options.c_pointer, nil),
        "w",
        &block
      )
    end
  end
end
