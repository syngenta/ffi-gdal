module GDAL
  module GridAlgorithms
    class DataMetricsBase
      # @return [FFI::GDAL::GridDataMetricsOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridDataMetricsOptions.new
      end
    end
  end
end