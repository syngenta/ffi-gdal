module GDAL
  # Getters and setters for the GDAL environment.
  module EnvironmentMethods
    # @return [Fixnum] The maximum cache memory.
    def cache_max
      FFI::GDAL::GDAL.GDALGetCacheMax
    end

    # @param bytes [Fixnum]
    def cache_max=(bytes)
      FFI::GDAL::GDAL.GDALSetCacheMax(bytes)
    end

    # @return [Fixnum] The maximum cache memory.
    def cache_max64
      FFI::GDAL::GDAL.GDALGetCacheMax64
    end

    # @param bytes [Fixnum]
    def cache_max64=(bytes)
      FFI::GDAL::GDAL.GDALSetCacheMax64(bytes)
    end

    # @return [Fixnum] The amount of used cache memory.
    def cache_used
      FFI::GDAL::GDAL.GDALGetCacheUsed
    end

    # @return [Fixnum] The amount of used cache memory.
    def cache_used64
      FFI::GDAL::GDAL.GDALGetCacheUsed64
    end

    # @return [Boolean]
    def flush_cache_block
      FFI::GDAL::GDAL.GDALFlushCacheBlock
    end

    # @param file_path [String]
    def dump_open_datasets(file_path)
      file_ptr = FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false)
      FFI::GDAL::GDAL.GDALDumpOpenDatasets(file_ptr)
      FFI::CPL::Conv.CPLCloseShared(file_ptr)
    end
  end
end