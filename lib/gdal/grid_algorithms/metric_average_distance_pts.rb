# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MetricAverageDistancePts < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridDataMetricsOptions
      end

      def c_identifier
        :GGA_MetricAverageDistancePts
      end
    end
  end
end
