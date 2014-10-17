require 'ffi'

module FFI
  module GDAL

    #-----------------------------------------------------------------
    # Enums
    #-----------------------------------------------------------------
    GDALDataType = enum :GDT_Unknown, 0,
      :GDT_Byte,        1,
      :GDT_UInt16,      2,
      :GDT_Int16,       3,
      :GDT_UInt32,      4,
      :GDT_Int32,       5,
      :GDT_Float32,     6,
      :GDT_Float64,     7,
      :GDT_CInt16,      8,
      :GDT_CInt32,      9,
      :GDT_CFloat32,    10,
      :GDT_CFloat64,    11,
      :GDT_TypeCount,   12

    GDALAsyncStatusType = enum :GARIO_PENDING, 0,
      :GARIO_UPDATE,     1,
      :GARIO_ERROR,      2,
      :GARIO_COMPLETE,   3,
      :GARIO_TypeCount,  4

    GDALAccess = enum :GA_ReadOnly, 0,
      :GA_Update, 1

    GDALRWFlag = enum :GF_Read, 0,
      :GF_Write, 1

    GDALColorInterp = enum :GCI_Undefined, 0,
      :GCI_GrayIndex,      1,
      :GCI_PaletteIndex,   2,
      :GCI_RedBand,        3,
      :GCI_GreenBand,      4,
      :GCI_BlueBand,       5,
      :GCI_AlphaBand,      6,
      :GCI_HueBand,        7,
      :GCI_SaturationBand, 8,
      :GCI_LightnessBand,  9,
      :GCI_CyanBand,       10,
      :GCI_MagentaBand,    11,
      :GCI_YellowBand,     12,
      :GCI_BlackBand,      13,
      :GCI_YCbCr_YBand,    14,
      :GCI_YCbCr_CbBand,   15,
      :GCI_YCbCr_CrBand,   16,
      :GCI_Max, 16      # Seems wrong that this is also 16...

    GDALPaletteInterp = enum :GPI_Gray, 0,
      :GPI_RGB,   1,
      :GPI_CMYK,  2,
      :GPI_HLS,   3

    GDALRATFieldType = enum :GFT_Integer,
      :GFT_Real,
      :GFT_String

    GDALRATFieldUsage = enum :GFU_Generic, 0,
      :GFU_PixelCount,  1,
      :GFU_Name,        2,
      :GFU_Min,         3,
      :GFU_Max,         4,
      :GFU_MinMax,      5,
      :GFU_Red,         6,
      :GFU_Green,       7,
      :GFU_Blue,        8,
      :GFU_Alpha,       9,
      :GFU_RedMin,     10,
      :GFU_GreenMin,   11,
      :GFU_BlueMin,    12,
      :GFU_AlphaMin,   13,
      :GFU_RedMax,     14,
      :GFU_GreenMax,   15,
      :GFU_BlueMax,    16,
      :GFU_AlphaMax,   17,
      :GFU_MaxCount

    GDALTileOrganization = enum :GTO_TIP,
      :GTO_BIT,
      :GTO_BSQ

    #-----------------------------------------------------------------
    # typedefs
    #-----------------------------------------------------------------
    typedef :pointer, :GDALMajorObjectH
    typedef :pointer, :GDALDatasetH
    typedef :pointer, :GDALRasterBandH
    typedef :pointer, :GDALDriverH
    typedef :pointer, :GDALColorTableH
    typedef :pointer, :GDALRasterAttributeTableH
    typedef :pointer, :GDALAsyncReaderH

    # When using, make sure to return +true+ if the operation should continue;
    #   +false+ if the user has cancelled.
    callback :GDALProgressFunc,
      [:double, :string, :pointer],     # completion, message, progress_arg
      :bool

    callback :GDALDerivedPixelFunc,
      [:pointer, :int, :pointer, :int, :int, GDALDataType, GDALDataType, :int, :int],
      :int
  end

end

# These requires depend on ^^^
require_relative 'alg_h'
require_relative 'grid_h'
require_relative 'warper_h'

module FFI
  module GDAL

    #-----------------------------------------------------------------
    # functions
    #-----------------------------------------------------------------
    # AsyncStatus
    attach_function :GDALGetAsyncStatusTypeName, [GDALAsyncStatusType], :string
    attach_function :GDALGetAsyncStatusTypeByName, [:string], GDALAsyncStatusType

    #~~~~~~~~~~~~~~~~~~~~
    # ColorInterpretation
    #~~~~~~~~~~~~~~~~~~~~
    attach_function :GDALGetColorInterpretationName, [GDALColorInterp], :string
    attach_function :GDALGetColorInterpretationByName, [:string], GDALColorInterp

    #~~~~~~~~~~~~~~~~~~~~
    # Driver
    #~~~~~~~~~~~~~~~~~~~~
    attach_function :GDALAllRegister, [], :void

    # Class-level functions
    attach_function :GDALGetDriver, [:int], :GDALDriverH
    attach_function :GDALGetDriverCount, [], :int
    attach_function :GDALIdentifyDriver, %i[string pointer], :GDALDriverH
    attach_function :GDALGetDriverByName, [:string], :GDALDriverH
    attach_function :GDALDestroyDriverManager, [:void], :void

    # Instance-level functions
    attach_function :GDALCreate,
      [:GDALDriverH, :string, :int, :int, :int, GDALDataType, :pointer],
      :GDALDatasetH
    attach_function :GDALCreateCopy,
      %i[GDALDriverH string GDALDatasetH bool pointer GDALProgressFunc pointer],
      :GDALDatasetH
    attach_function :GDALValidateCreationOptions, %i[GDALDriverH pointer], CPLErr
    attach_function :GDALGetDriverShortName, [:GDALDriverH], :string
    attach_function :GDALGetDriverLongName, [:GDALDriverH], :string
    attach_function :GDALGetDriverHelpTopic, [:GDALDriverH], :string
    attach_function :GDALGetDriverCreationOptionList, [:GDALDriverH], :string

    attach_function :GDALDestroyDriver, [:GDALDriverH], :void
    attach_function :GDALRegisterDriver, [:GDALDriverH], :int
    attach_function :GDALDeregisterDriver, [:GDALDriverH], :void
    attach_function :GDALDeleteDataset, [:GDALDriverH, :string], CPLErr
    attach_function :GDALRenameDataset,
      %i[GDALDriverH string string],
      CPLErr
    attach_function :GDALCopyDatasetFiles,
      %i[GDALDriverH string string],
      CPLErr

    #~~~~~~~~~~~~~~~~~~~~
    # Dataset
    #~~~~~~~~~~~~~~~~~~~~
    # Class-level functions
    attach_function :GDALOpen, [:string, GDALAccess], :GDALDatasetH
    attach_function :GDALOpenShared,
      [:string, GDALAccess],
      :GDALDatasetH
    attach_function :GDALOpenEx,
      %i[string uint string string string],
      :GDALDatasetH
    attach_function :GDALDumpOpenDatasets, [:pointer], :int
    attach_function :GDALGetOpenDatasets, [:pointer, :pointer], :void

    # Instance-level functions
    attach_function :GDALClose, [:GDALDatasetH], :void
    attach_function :GDALGetDatasetDriver, [:GDALDatasetH], :GDALDriverH
    attach_function :GDALGetFileList, [:GDALDatasetH], :pointer
    attach_function :GDALGetInternalHandle, [:GDALDatasetH, :string], :pointer
    attach_function :GDALReferenceDataset, [:GDALDatasetH], :int
    attach_function :GDALDereferenceDataset, [:GDALDatasetH], :int

    attach_function :GDALGetAccess, [:GDALDatasetH], :int
    attach_function :GDALFlushCache, [:GDALDatasetH], :void

    attach_function :GDALGetRasterXSize, [:GDALDatasetH], :int
    attach_function :GDALGetRasterYSize, [:GDALDatasetH], :int
    attach_function :GDALGetRasterCount, [:GDALDatasetH], :int
    attach_function :GDALGetRasterBand, [:GDALDatasetH, :int], :GDALRasterBandH
    attach_function :GDALAddBand,
      [:GDALDatasetH, GDALDataType, :pointer],
      CPLErr
    attach_function :GDALBeginAsyncReader,
      [
        :GDALDatasetH,
        GDALRWFlag,
        :int,
        :int,
        :int,
        :int,
        :pointer,
        :int,
        :int,
        GDALDataType,
        :int,
        :pointer,
        :int,
        :int,
        :int
      ], :GDALAsyncReaderH

    attach_function :GDALEndAsyncReader,
      [:GDALDatasetH, :GDALAsyncReaderH],
      :void

    attach_function :GDALDatasetRasterIO,
      [
        :GDALDatasetH,
        GDALRWFlag,
        :int,
        :int,
        :int,
        :int,
        :pointer,
        :int,
        :int,
        GDALDataType,
        :int,
        :pointer,
        :int,
        :int,
        :int
      ], CPLErr

    attach_function :GDALDatasetAdviseRead,
      [
        :GDALDatasetH,
        :int,
        :int,
        :int,
        :int,
        :int,
        :int,
        GDALDataType,
        :int,
        :pointer,
        :pointer
      ], CPLErr

    attach_function :GDALInitGCPs, [:int, :pointer], :void
    attach_function :GDALDeinitGCPs, [:int, :pointer], :void
    attach_function :GDALDuplicateGCPs, [:int, :pointer], :pointer
    attach_function :GDALGCPsToGeoTransform,
      [:int, :pointer, :pointer, :int],
      :int
    attach_function :GDALGetGCPCount, [:GDALDatasetH], :int
    attach_function :GDALGetGCPProjection, [:GDALDatasetH], :string
    attach_function :GDALGetGCPs, [:GDALDatasetH], :pointer
    attach_function :GDALSetGCPs,
      [:GDALDatasetH, :int, :pointer, :string],
      CPLErr

    attach_function :GDALGetProjectionRef, [:GDALDatasetH], :string
    attach_function :GDALSetProjection, [:GDALDatasetH, :string], CPLErr
    attach_function :GDALGetGeoTransform, [:GDALDatasetH, :pointer], CPLErr
    attach_function :GDALSetGeoTransform,
      [:GDALDatasetH, :pointer],
      CPLErr

    attach_function :GDALBuildOverviews,
      [
        :GDALDatasetH,
        :string,
        :int,
        :pointer,
        :int,
        :pointer,
        :GDALProgressFunc,
        :pointer
      ], CPLErr

    # OGR datasets.  Not found in v1.11.1
    attach_function :GDALDatasetGetLayerCount, [:GDALDatasetH], :int
    attach_function :GDALDatasetGetLayer, [:GDALDatasetH, :int], :OGRLayerH
    attach_function :GDALDatasetGetLayerByName, [:GDALDatasetH, :string], :OGRLayerH
    attach_function :GDALDatasetDeleteLayer, [:GDALDatasetH, :int], OGRErr
    attach_function :GDALDatasetCreateLayer,
      [:GDALDatasetH, :string, :OGRSpatialReferenceH, OGRwkbGeometryType, :pointer],
      :OGRLayerH
    attach_function :GDALDatasetCopyLayer,
      %i[GDALDatasetH OGRLayerH string pointer],
      :OGRLayerH
    attach_function :GDALDatasetTestCapability, [:GDALDatasetH, :string], :int
    attach_function :GDALDatasetExecuteSQL,
      [:GDALDatasetH, :string, :OGRGeometryH, :string],
      :OGRLayerH
    attach_function :GDALDatasetReleaseResultSet,
      %i[GDALDatasetH OGRLayerH],
      :void
    attach_function :GDALDatasetGetStyleTable, [:GDALDatasetH], :OGRStyleTableH
    attach_function :GDALDatasetSetStyleTableDirectly,
      %i[GDALDatasetH OGRStyleTableH],
      :void
    attach_function :GDALDatasetSetStyleTable,
      %i[GDALDatasetH OGRStyleTableH],
      :void

    attach_function :GDALCreateDatasetMaskBand, [:GDALDatasetH, :int], CPLErr
    attach_function :GDALDatasetCopyWholeRaster,
      %i[GDALDatasetH GDALDatasetH pointer GDALProgressFunc pointer],
      CPLErr

    #~~~~~~~~~~~~~~~~~~~~
    # MajorObject
    #~~~~~~~~~~~~~~~~~~~~
    attach_function :GDALGetMetadataDomainList, [:GDALMajorObjectH], :pointer
    attach_function :GDALGetMetadata, %i[GDALMajorObjectH string], :pointer
    attach_function :GDALSetMetadata, %i[GDALMajorObjectH pointer string], CPLErr
    attach_function :GDALGetMetadataItem,
      %i[GDALMajorObjectH string string],
      :string
    attach_function :GDALSetMetadataItem,
      %i[GDALMajorObjectH string string string],
      CPLErr
    attach_function :GDALGetDescription, [:GDALMajorObjectH], :string
    attach_function :GDALSetDescription, %i[GDALMajorObjectH string], :void

    #~~~~~~~~~~~~~~~~~~~~
    # GeoTransform
    #~~~~~~~~~~~~~~~~~~~~
    attach_function :GDALInvGeoTransform, %i[pointer pointer], :int
    attach_function :GDALApplyGeoTransform,
      %i[pointer double double pointer pointer],
      :void
    attach_function :GDALComposeGeoTransforms,
      %i[pointer pointer pointer],
      :void

    #-----------------
    # Raster functions
    #-----------------
    attach_function :GDALRasterBandCopyWholeRaster,
      [
        :GDALRasterBandH,
        :GDALRasterBandH,
        :pointer,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALRegenerateOverviews,
      [
        :GDALRasterBandH,
        :int,
        :pointer,
        :string,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALGetMaskBand, [:GDALRasterBandH], :GDALRasterBandH
    attach_function :GDALGetMaskFlags, [:GDALRasterBandH], :int
    attach_function :GDALCreateMaskBand,
      [:GDALRasterBandH, :int],
      CPLErr

    attach_function :GDALGetRasterDataType, [:GDALRasterBandH], GDALDataType
    attach_function :GDALGetBlockSize,
      [:GDALRasterBandH, :pointer, :pointer],
      GDALDataType

    attach_function :GDALRasterAdviseRead,
      [
        :GDALRasterBandH,
        :int,
        :int,
        :int,
        :int,
        :int,
        :int,
        GDALDataType,
        :pointer
      ], CPLErr

    attach_function :GDALRasterIO,
      [
        :GDALRasterBandH,
        GDALRWFlag,
        :int,
        :int,
        :int,
        :int,
        :pointer,
        :int,
        :int,
        GDALDataType,
        :int,
        :int
      ], CPLErr
    attach_function :GDALReadBlock,
      [:GDALRasterBandH, :int, :int, :pointer],
      CPLErr
    attach_function :GDALWriteBlock,
      [:GDALRasterBandH, :int, :int, :pointer],
      CPLErr
    attach_function :GDALGetRasterBandXSize, [:GDALRasterBandH], :int
    attach_function :GDALGetRasterBandYSize, [:GDALRasterBandH], :int
    attach_function :GDALGetRasterAccess, [:GDALRasterBandH], GDALAccess
    attach_function :GDALGetBandNumber, [:GDALRasterBandH], :int
    attach_function :GDALGetBandDataset, [:GDALRasterBandH], :GDALDatasetH
    attach_function :GDALGetRasterColorInterpretation,
      [:GDALRasterBandH],
      GDALColorInterp
    attach_function :GDALSetRasterColorInterpretation,
      [:GDALRasterBandH, GDALColorInterp],
      CPLErr
    attach_function :GDALGetRasterColorTable,
      [:GDALRasterBandH],
      :GDALColorTableH
    attach_function :GDALSetRasterColorTable,
      [:GDALRasterBandH, :GDALColorTableH],
      CPLErr

    attach_function :GDALHasArbitraryOverviews, [:GDALRasterBandH], :int
    attach_function :GDALGetOverviewCount, [:GDALRasterBandH], :int
    attach_function :GDALGetOverview, [:GDALRasterBandH, :int], :GDALRasterBandH
    attach_function :GDALGetRasterNoDataValue,
      [:GDALRasterBandH, :pointer],
      :double
    attach_function :GDALSetRasterNoDataValue,
      [:GDALRasterBandH, :double],
      CPLErr
    attach_function :GDALGetRasterCategoryNames,
      [:GDALRasterBandH],
      :pointer
    attach_function :GDALSetRasterCategoryNames,
      [:GDALRasterBandH, :pointer],
      CPLErr
    attach_function :GDALGetRasterMinimum,
      [:GDALRasterBandH, :pointer],
      :double
    attach_function :GDALGetRasterMaximum,
      [:GDALRasterBandH, :pointer],
      :double
    attach_function :GDALGetRasterStatistics,
      [:GDALRasterBandH, :bool, :bool, :pointer, :pointer, :pointer, :pointer],
      CPLErr
    attach_function :GDALComputeRasterStatistics,
      [
        :GDALRasterBandH,
        :bool,
        :pointer,
        :pointer,
        :pointer,
        :pointer,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALSetRasterStatistics,
      [:GDALRasterBandH, :double, :double, :double, :double],
      CPLErr
    attach_function :GDALGetRasterUnitType, [:GDALRasterBandH], :string
    attach_function :GDALSetRasterUnitType, [:GDALRasterBandH, :string], CPLErr
    attach_function :GDALGetRasterOffset, [:GDALRasterBandH, :pointer], :double
    attach_function :GDALSetRasterOffset, [:GDALRasterBandH, :double], CPLErr
    attach_function :GDALGetRasterScale, [:GDALRasterBandH, :pointer], :double
    attach_function :GDALSetRasterScale, [:GDALRasterBandH, :double], CPLErr
    attach_function :GDALComputeRasterMinMax,
      [:GDALRasterBandH, :int, :pointer],
      :void
    attach_function :GDALFlushRasterCache, [:GDALRasterBandH], CPLErr
    attach_function :GDALGetRasterHistogram,
      [
        :GDALRasterBandH,
        :double,
        :double,
        :int,
        :pointer,
        :bool,
        :bool,
        :GDALProgressFunc,
        :pointer
      ], CPLErr

    attach_function :GDALGetDefaultHistogram,
      [
        :GDALRasterBandH,
        :pointer,
        :pointer,
        :pointer,
        :pointer,
        :bool,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALSetDefaultHistogram,
      [
        :GDALRasterBandH,
        :double,
        :double,
        :int,
        :pointer
      ], CPLErr

    attach_function :GDALGetRandomRasterSample,
      [:GDALRasterBandH, :int, :pointer],
      :int
    attach_function :GDALGetRasterSampleOverview,
      [:GDALRasterBandH, :int],
      :GDALRasterBandH
    attach_function :GDALFillRaster,
      [:GDALRasterBandH, :double, :double],
      CPLErr

    attach_function :GDALGetDefaultRAT,
      [:GDALRasterBandH],
      :GDALRasterAttributeTableH
    attach_function :GDALSetDefaultRAT,
      [:GDALRasterBandH, :GDALRasterAttributeTableH],
      CPLErr
    attach_function :GDALAddDerivedBandPixelFunc,
      [:string, :GDALDerivedPixelFunc],
      CPLErr

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Raster Attribute Table functions
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Class-level functions
    attach_function :GDALCreateRasterAttributeTable,
      [],
      :GDALRasterAttributeTableH

    # Instance-level functions
    attach_function :GDALDestroyRasterAttributeTable,
      [:GDALRasterAttributeTableH],
      :void
    attach_function :GDALRATChangesAreWrittenToFile,
      [:GDALRasterAttributeTableH],
      :bool
    attach_function :GDALRATClone,
      [:GDALRasterAttributeTableH],
      :GDALRasterAttributeTableH

    attach_function :GDALRATGetColumnCount,
      [:GDALRasterAttributeTableH],
      :int
    attach_function :GDALRATGetNameOfCol,
      [:GDALRasterAttributeTableH, :int],
      :string
    attach_function :GDALRATGetUsageOfCol,
      [:GDALRasterAttributeTableH, :int],
      GDALRATFieldUsage
    attach_function :GDALRATGetTypeOfCol,
      [:GDALRasterAttributeTableH, :int],
      GDALRATFieldType
    attach_function :GDALRATGetColOfUsage,
      [:GDALRasterAttributeTableH, GDALRATFieldUsage],
      :int
    attach_function :GDALRATCreateColumn,
      [:GDALRasterAttributeTableH, :string, GDALRATFieldType, GDALRATFieldUsage],
      CPLErr

    attach_function :GDALRATGetValueAsString,
      %i[GDALRasterAttributeTableH int int],
      :string
    attach_function :GDALRATGetValueAsInt,
      %i[GDALRasterAttributeTableH int int],
      :int
    attach_function :GDALRATGetValueAsDouble,
      %i[GDALRasterAttributeTableH int int],
      :double
    attach_function :GDALRATSetValueAsString,
      %i[GDALRasterAttributeTableH int int string],
      :void
    attach_function :GDALRATSetValueAsInt,
      %i[GDALRasterAttributeTableH int int int],
      :void
    attach_function :GDALRATSetValueAsDouble,
      %i[GDALRasterAttributeTableH int int double],
      :void
    attach_function :GDALRATValuesIOAsDouble,
      [:GDALRasterAttributeTableH, GDALRWFlag, :int, :int, :int, :pointer],
      CPLErr
    attach_function :GDALRATValuesIOAsInteger,
      [:GDALRasterAttributeTableH, GDALRWFlag, :int, :int, :int, :pointer],
      CPLErr
    attach_function :GDALRATValuesIOAsString,
      [:GDALRasterAttributeTableH, GDALRWFlag, :int, :int, :int, :pointer],
      CPLErr

    attach_function :GDALRATGetRowCount,
      [:GDALRasterAttributeTableH],
      :int
    attach_function :GDALRATSetRowCount,
      %i[GDALRasterAttributeTableH int],
      :void
    attach_function :GDALRATGetRowOfValue,
      %i[GDALRasterAttributeTableH double],
      :int

    attach_function :GDALRATSetLinearBinning,
      %i[GDALRasterAttributeTableH double double],
      :int
    attach_function :GDALRATGetLinearBinning,
      %i[GDALRasterAttributeTableH pointer pointer],
      :int
    attach_function :GDALRATTranslateToColorTable,
      %i[GDALRasterAttributeTableH int],
      :GDALColorTableH
    attach_function :GDALRATInitializeFromColorTable,
      %i[GDALRasterAttributeTableH GDALColorTableH],
      CPLErr

    attach_function :GDALRATDumpReadable,
      %i[GDALRasterAttributeTableH string],
      :void

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # ColorTable functions
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Class-level functions
    attach_function :GDALCreateColorTable, [GDALPaletteInterp], :GDALColorTableH

    # Instance-level functions
    attach_function :GDALDestroyColorTable, [:GDALColorTableH], :void
    attach_function :GDALCloneColorTable, [:GDALColorTableH], :GDALColorTableH

    attach_function :GDALGetPaletteInterpretation, [:GDALColorTableH], GDALPaletteInterp
    attach_function :GDALGetColorEntryCount, [:GDALColorTableH], :int
    attach_function :GDALGetColorEntry, [:GDALColorTableH, :int], GDALColorEntry.ptr
    attach_function :GDALGetColorEntryAsRGB, [:GDALColorTableH, :int, GDALColorEntry], :int
    attach_function :GDALSetColorEntry, [:GDALColorTableH, :int, GDALColorEntry.ptr], :void

    attach_function :GDALCreateColorRamp,
      [:GDALColorTableH, :int, GDALColorEntry.ptr, :int, GDALColorEntry.ptr],
      :void

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # PaletteInterp functions
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attach_function :GDALGetPaletteInterpretationName, [GDALPaletteInterp], :string

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # General stuff
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    attach_function :GDALGetDataTypeSize, [GDALDataType], :int
    attach_function :GDALDataTypeIsComplex, [GDALDataType], :bool
    attach_function :GDALGetDataTypeName, [GDALDataType], :string
    attach_function :GDALGetDataTypeByName, [:string], GDALDataType
    attach_function :GDALDataTypeUnion, [GDALDataType, GDALDataType], GDALDataType

    attach_function :GDALSetCacheMax, %i[int], :void
    attach_function :GDALSetCacheMax64, %i[GIntBig], :void
    attach_function :GDALGetCacheMax, [], :int
    attach_function :GDALGetCacheMax64, [], :GIntBig
    attach_function :GDALGetCacheUsed, [], :int
    attach_function :GDALGetCacheUsed64, [], :GIntBig
    attach_function :GDALFlushCacheBlock, [], :bool

    attach_function :GDALLoadWorldFile, %i[string pointer], :bool
    attach_function :GDALReadWorldFile, %i[string string pointer], :bool
    attach_function :GDALWriteWorldFile, %i[string string pointer], :bool

    attach_function :GDALPackedDMSToDec, %i[double], :double
    attach_function :GDALDecToPackedDMS, %i[double], :double

    attach_function :GDALGeneralCmdLineProcessor, %i[int pointer int], :int
    attach_function :GDALSwapWords,
      %i[pointer int int int],
      :void
    attach_function :GDALCopyWords,
      %i[pointer int int pointer int int int int],
      :void
    attach_function :GDALCopyBits,
      %i[pointer int int pointer int int int int],
      :void
  end
end
