# frozen_string_literal: true

require_relative "../../gdal"
require_relative "options_list"

module GDAL
  module Utils
    class InfoOptions
      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::Utils.GDALInfoOptionsFree(pointer)
      end

      # @return [FFI::Pointer] C pointer to the GDALInfoOptions.
      attr_reader :c_pointer

      attr_reader :options, :options_list

      def initialize(options: [])
        @options = options
        @options_list = OptionsList.new(options: options)
        @c_pointer = FFI::AutoPointer.new(options_pointer, InfoOptions.method(:release))
      end

      private

      def options_pointer
        FFI::GDAL::Utils.GDALInfoOptionsNew(options_list.c_pointer, nil)
      end
    end
  end
end
