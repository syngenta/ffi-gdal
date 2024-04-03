# frozen_string_literal: true

require_relative "../../gdal"

module GDAL
  module Utils
    class OptionsList
      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::CPL::String.CSLDestroy(pointer)
      end

      # @return [FFI::Pointer] C pointer to the GDALInfoOptions.
      attr_reader :c_pointer

      attr_reader :options

      def initialize(options: [])
        @options = options
        @c_pointer = options_list_autopointer
      end

      private

      def options_list_autopointer
        FFI::AutoPointer.new(options_list_pointer, OptionsList.method(:release))
      end

      def options_list_pointer
        options_ptr = FFI::Pointer.new(FFI::Pointer::NULL)

        options.each do |value|
          options_ptr = FFI::CPL::String.CSLAddString(options_ptr, value.to_s)
        end

        options_ptr
      end
    end
  end
end
