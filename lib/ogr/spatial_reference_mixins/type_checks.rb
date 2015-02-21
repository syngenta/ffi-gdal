module OGR
  module SpatialReferenceMixins
    module TypeChecks
      # @return [Boolean] True if the root node is a GEOGCS node.
      def geographic?
        FFI::OGR::SRSAPI.OSRIsGeographic(@ogr_spatial_ref_pointer)
      end

      # @return [Boolean] True if the root node is a LOCAL_CS node.
      def local?
        FFI::OGR::SRSAPI.OSRIsLocal(@ogr_spatial_ref_pointer)
      end

      # @return [Boolean] True if it contains a PROJCS node.
      def projected?
        FFI::OGR::SRSAPI.OSRIsProjected(@ogr_spatial_ref_pointer)
      end

      # @return [Boolean] True if the root node is a COMPD_CS node.
      def compound?
        FFI::OGR::SRSAPI.OSRIsCompound(@ogr_spatial_ref_pointer)
      end

      # @return [Boolean] True if the root node is a GEOCCS node.
      def geocentric?
        FFI::OGR::SRSAPI.OSRIsGeocentric(@ogr_spatial_ref_pointer)
      end

      # @return [Boolean] True if it contains a VERT_CS node.
      def vertical?
        FFI::OGR::SRSAPI.OSRIsVertical(@ogr_spatial_ref_pointer)
      end

      # @param other_spatial_ref [OGR::SpatialReference, FFI::Pointer]
      # @return [Boolean] True if both SpatialReferences describe the same
      #   system.
      def same?(other_spatial_ref)
        spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, other_spatial_ref)

        FFI::OGR::SRSAPI.OSRIsSame(@ogr_spatial_ref_pointer, spatial_ref_ptr)
      end

      # @param other_spatial_ref [OGR::SpatialReference, FFI::Pointer]
      # @return [Boolean] True if the GEOCCS nodes of each SpatialReference
      #   match.
      def geog_cs_is_same?(other_spatial_ref)
        spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, other_spatial_ref)

        FFI::OGR::SRSAPI.OSRIsSameGeogCS(@ogr_spatial_ref_pointer, spatial_ref_ptr)
      end

      # @param other_spatial_ref [OGR::SpatialReference, FFI::Pointer]
      # @return [Boolean] True if the VERT_CS nodes of each SpatialReference
      #   match.
      def vert_cs_is_same?(other_spatial_ref)
        spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, other_spatial_ref)

        FFI::OGR::SRSAPI.OSRIsSameVertCS(@ogr_spatial_ref_pointer, spatial_ref_ptr)
      end
    end
  end
end
