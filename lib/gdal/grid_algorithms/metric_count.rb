# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MetricCount < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridDataMetricsOptions
      end

      def c_identifier
        :GGA_MetricCount
      end
    end
  end
end
