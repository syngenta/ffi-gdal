# frozen_string_literal: true

require_relative "nearblack/options"

module GDAL
  module Utils
    # Wrapper for nearblack using GDALNearblack C API.
    #
    # @see https://gdal.org/programs/nearblack.html nearblack utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv413GDALNearblackPKc12GDALDatasetH12GDALDatasetHPK20GDALNearblackOptionsPi
    #   GDALNearblack C API.
    class Nearblack
      # Perform the nearblack (GDALNearblack) operation.
      #
      # @example Perform nearblack on dataset (for dst_dataset_path).
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #
      #   dataset = GDAL::Utils::Nearblack.perform(dst_dataset_path: "destination.tif", src_dataset: src_dataset)
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Perform nearblack on dataset with options (for dst_dataset_path).
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   options = GDAL::Utils::Nearblack::Options.new(options: ["-near", "10"])
      #
      #   dataset = GDAL::Utils::Nearblack.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     options: options
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Perform nearblack on dataset (for dst_dataset_path) using block syntax.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   options = GDAL::Utils::Nearblack::Options.new(options: ["-near", "10"])
      #
      #   GDAL::Utils::Nearblack.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     options: options
      #   ) do |dataset|
      #     # Do something with the dataset.
      #     puts dataset.raster_x_size
      #
      #     # Dataset will be closed automatically.
      #   end
      #   src_dataset.close
      #
      # @example Perform nearblack on dataset (for dst_dataset).
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   dst_dataset = GDAL::Dataset.open("destination.tif", "w")
      #
      #   GDAL::Utils::Nearblack.perform(dst_dataset: dst_dataset, src_dataset: src_dataset)
      #
      #   # You must close the dataset when you are done with it.
      #   dst_dataset.close
      #   src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param dst_dataset [GDAL::Dataset] The destination dataset.
      # @param src_dataset [GDAL::Dataset] The source dataset.
      # @param options [GDAL::Utils::Nearblack::Options] Options.
      # @yield [GDAL::Dataset] The destination dataset.
      # @return [GDAL::Dataset] The destination dataset (only if block is not specified; dataset must be closed).
      def self.perform(src_dataset:, dst_dataset: nil, dst_dataset_path: nil, options: Options.new, &block)
        if dst_dataset
          for_dataset(dst_dataset: dst_dataset, src_dataset: src_dataset, options: options)
        else
          for_dataset_path(dst_dataset_path: dst_dataset_path, src_dataset: src_dataset, options: options, &block)
        end
      end

      def self.for_dataset(dst_dataset:, src_dataset:, options: Options.new)
        result_dataset_ptr(dst_dataset: dst_dataset, src_dataset: src_dataset, options: options)

        # Return the input dataset as the output dataset (dataset is modified in place).
        dst_dataset
      end
      private_class_method :for_dataset

      def self.for_dataset_path(dst_dataset_path:, src_dataset:, options: Options.new, &block)
        dst_dataset_ptr = result_dataset_ptr(
          dst_dataset_path: dst_dataset_path, src_dataset: src_dataset, options: options
        )

        ::GDAL::Dataset.open(dst_dataset_ptr, "w", &block)
      end
      private_class_method :for_dataset_path

      def self.result_dataset_ptr(src_dataset:, dst_dataset_path: nil, dst_dataset: nil, options: Options.new)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALNearblack(
          dst_dataset_path,
          dst_dataset&.c_pointer,
          src_dataset.c_pointer,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALNearblack failed." if dst_dataset_ptr.null? || !success

        dst_dataset_ptr
      end
      private_class_method :result_dataset_ptr
    end
  end
end
