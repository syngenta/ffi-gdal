module GDAL
  class DataType
    # The size in bits.
    #
    # @param gdal_data_type [FFI::GDAL::DataType]
    # @return [Fixnum]
    def self.size(gdal_data_type)
      FFI::GDAL.GDALGetDataTypeSize(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::DataType]
    # @return [Fixnum]
    def self.complex?(gdal_data_type)
      FFI::GDAL.GDALDataTypeIsComplex(gdal_data_type)
    end

    # @param gdal_data_type [FFI::GDAL::DataType]
    # @return [String]
    def self.name(gdal_data_type)
      FFI::GDAL.GDALGetDataTypeName(gdal_data_type)
    end

    # The data type's symbolic name.
    #
    # @param name [String]
    # @return [FFI::GDAL::DataType]
    def self.by_name(name)
      FFI::GDAL.GDALGetDataTypeByName(name)
    end

    # @param gdal_data_type1 [FFI::GDAL::DataType]
    # @param gdal_data_type2 [FFI::GDAL::DataType]
    # @return [FFI::GDAL::DataType]
    def self.union(gdal_data_type1, gdal_data_type2)
      FFI::GDAL.GDALDataTypeUnion(gdal_data_type1, gdal_data_type2)
    end
  end
end
