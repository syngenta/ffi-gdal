# frozen_string_literal: true

require "ffi"
require_relative "../../ext/ffi_library_function_checks"

module FFI
  module GDAL
    module Utils
      extend FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------

      # https://gdal.org/api/gdal_utils.html#_CPPv415GDALInfoOptions
      typedef :pointer, :GDALInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv420GDALTranslateOptions
      typedef :pointer, :GDALTranslateOptions

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------

      # https://gdal.org/api/gdal_utils.html#_CPPv418GDALInfoOptionsNewPPcP24GDALInfoOptionsForBinary
      attach_function :GDALInfoOptionsNew, %i[pointer pointer], :GDALInfoOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv419GDALInfoOptionsFreeP15GDALInfoOptions
      attach_function :GDALInfoOptionsFree, [:GDALInfoOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv48GDALInfo12GDALDatasetHPK15GDALInfoOptions
      attach_function :GDALInfo, [FFI::GDAL::GDAL.find_type(:GDALDatasetH), :GDALInfoOptions], :strptr

      # https://gdal.org/api/gdal_utils.html#_CPPv423GDALTranslateOptionsNewPPcP29GDALTranslateOptionsForBinary
      attach_function :GDALTranslateOptionsNew, %i[pointer pointer], :GDALTranslateOptions

      # https://gdal.org/api/gdal_utils.html#_CPPv424GDALTranslateOptionsFreeP20GDALTranslateOptions
      attach_function :GDALTranslateOptionsFree, [:GDALTranslateOptions], :void

      # https://gdal.org/api/gdal_utils.html#_CPPv413GDALTranslatePKc12GDALDatasetHPK20GDALTranslateOptionsPi
      attach_function :GDALTranslate,
                      [:string, FFI::GDAL::GDAL.find_type(:GDALDatasetH), :GDALTranslateOptions, :pointer],
                      FFI::GDAL::GDAL.find_type(:GDALDatasetH)
    end
  end
end
