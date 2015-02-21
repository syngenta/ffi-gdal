require 'ffi'
require_relative 'gdal_rpc_info'
require_relative '../ogr/api'

module FFI
  module GDAL
    module Alg
      extend FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      GridAlgorithm = enum :GGA_InverseDistanceToAPower, 1,
        :GGA_MovingAverage, 2,
        :GGA_NearestNeighbor, 3,
        :GGA_MetricMinimum, 4,
        :GGA_MetricMaximum, 5,
        :GGA_MetricRange, 6,
        :GGA_MetricCount, 7,
        :GGA_MetricAverageDistance, 8,
        :GGA_MetricAverageDistancePts, 9

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      callback :GDALTransformerFunc,
        %i[pointer int int pointer pointer pointer pointer],
        :int

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :GDALApproxTransform,
        %i[pointer int int pointer pointer pointer pointer],
        :int
      attach_function :GDALChecksumImage,
        %i[GDALRasterBandH int int int int],
        :int
      attach_function :GDALComputeMedianCutPCT,
        %i[GDALRasterBandH GDALRasterBandH GDALRasterBandH pointer
           int GDALColorTableH GDALProgressFunc pointer],
        :int
      attach_function :GDALComputeProximity,
        %i[GDALRasterBandH GDALRasterBandH pointer GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALContourGenerate,
        %i[GDALRasterBandH double double int pointer int double pointer
           int int GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALCreateApproxTransformer,
        %i[GDALTransformerFunc pointer double],
        :pointer
      attach_function :GDALCreateGCPTransformer, %i[int pointer int int], :pointer
      attach_function :GDALCreateGenImgProjTransformer,
        %i[GDALDatasetH string GDALDatasetH string bool double int],
        :pointer
      attach_function :GDALCreateGenImgProjTransformer2,
        %i[GDALDatasetH GDALDatasetH pointer],
        :pointer
      attach_function :GDALCreateReprojectionTransformer,
        %i[string string],
        :pointer
      attach_function :GDALCreateRPCTransformer,
        [GDALRPCInfo.ptr, :int, :double, :pointer],
        :pointer
      attach_function :GDALCreateTPSTransformer, %i[int pointer int], :pointer

      attach_function :GDALDestroyApproxTransformer, %i[pointer], :void
      attach_function :GDALDestroyGCPTransformer, %i[pointer], :pointer
      attach_function :GDALDestroyGenImgProjTransformer, %i[pointer], :pointer
      attach_function :GDALDestroyReprojectionTransformer, %i[pointer], :pointer
      attach_function :GDALDestroyTPSTransformer, %i[pointer], :pointer

      attach_function :GDALDitherRGB2PCT,
        %i[GDALRasterBandH GDALRasterBandH GDALRasterBandH GDALRasterBandH
           GDALColorTableH GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALPolygonize,
        %i[GDALRasterBandH GDALRasterBandH OGRLayerH int pointer GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALFPolygonize,
        %i[GDALRasterBandH GDALRasterBandH OGRLayerH int pointer
           GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALGCPTransform,
        %i[pointer int int pointer pointer pointer pointer],
        :bool
      attach_function :GDALGenImgProjTransform,
        %i[pointer int int pointer pointer pointer pointer],
        :bool

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Dataset-related
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_function :GDALGridCreate,
        [GDALGridAlgorithm, :pointer, :GUInt32, :pointer, :pointer, :pointer,
         :double, :double, :double, :double, :GUInt32, :GUInt32, GDAL::DataType,
         :pointer, :GDALProgressFunc, :pointer],
        CPLErr
      attach_function :GDALRasterizeGeometries,
        %i[GDALDatasetH int pointer int pointer GDALTransformerFunc
           pointer pointer pointer GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALRasterizeLayers,
        %i[GDALDatasetH int pointer int pointer GDALTransformerFunc
           pointer pointer pointer GDALProgressFunc pointer],
        CPLErr
      attach_function :GDALRasterizeLayersBuf,
        [:pointer, :int, :int, GDALDataType, :int, :int, :int, :pointer, :string,
         :pointer, :GDALTransformerFunc, :pointer, :double, :pointer,
         :GDALProgressFunc, :pointer],
        CPLErr

      attach_function :GDALReprojectionTransform,
        %i[pointer int int pointer pointer pointer pointer],
        :int
      attach_function :GDALSetGenImgProjTransformerDstGeoTransform,
        %i[pointer pointer],
        :void
      attach_function :GDALSimpleImageWarp,
        %i[GDALDatasetH GDALDatasetH int pointer GDALTransformerFunc pointer
           GDALProgressFunc pointer pointer],
        :bool
      attach_function :GDALSuggestedWarpOutput,
        %i[GDALDatasetH GDALTransformerFunc pointer pointer pointer pointer],
        CPLErr
    end
  end
end
