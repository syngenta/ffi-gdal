require 'json'

module OGR
  module FeatureExtensions
    # Retrieves the value for each field and yields it.
    #
    # @return [Enumerator]
    # @yieldparam [Number, String, Array]
    def each_field
      return enum_for(:each_field) unless block_given?

      field_count.times do |i|
        yield field(i)
      end
    end

    # @return [Array] Uses each FieldDefinition to determine the field type at
    #   each index and returns maps the field as that value type.
    def fields
      each_field.to_a
    end

    # Retrieves a field using +index+, but uses its type from the associated
    # {OGR::FieldDefinition} to determine it's core type to return as. This
    # saves from having to find out the type then call the associated
    # +field_as_[type]+ method if you just want the data in it's originally
    # intended form.
    #
    # @param index [Fixnum] Index of the field to retrieve the data for.
    # @return [Number, String, Array]
    # @raise [OGR::UnsupportedFieldType] if the associated FieldDefinition's
    #   type has not yet been mapped here (to know how to return the value).
    def field(index)
      field_type = field_definition(index).type

      case field_type
      when :OFTInteger        then field_as_integer(index)
      when :OFTIntegerList    then field_as_integer_list(index)
      when :OFTReal           then field_as_double(index)
      when :OFTRealList       then field_as_double_list(index)
      when :OFTString         then field_as_string(index)
      when :OFTStringList     then field_as_string_list(index)
      when :OFTWideString     then field_as_string(index)
      when :OFTWideStringList then field_as_string_list(index)
      when :OFTBinary         then field_as_binary(index)
      when :OFTDate, :OFTTime, :OFTDateTime then field_as_date_time(index)
      when :OFTInteger64      then field_as_integer(index)
      when :OFTInteger64List  then field_as_integer_lsit(index)
      when :OFTMaxType        then field_as_date_time(index)
      else raise OGR::UnsupportedFieldType,
        "Don't know how to fetch field for field type: #{field_type}"
      end
    end

    # @return [Enumerator]
    # @yieldparam [OGR::GeometryFieldDefinition]
    def each_geometry_field_definition
      return enum_for(:each_geometry_field_definition) unless block_given?

      geometry_field_count.times do |i|
        yield geometry_field_definition(i)
      end
    end

    # @return [Array<OGR::GeometryFieldDefinition>]
    def geometry_field_definitions
      each_geometry_field_definition.to_a
    end

    # @return [Enumerator]
    # @yieldparam [OGR::Geometry]
    def each_geometry_field
      return enum_for(:each_geometry_field) unless block_given?

      geometry_field_count.times do |i|
        yield geometry_field(i)
      end
    end

    # @return [Array<OGR::Geometry>]
    def geometry_fields
      each_geometry_field.to_a
    end

    # @return [Hash]
    def as_json(options = nil)
      fields_with_nested_json = fields.map.with_index do |f, i|
        {
          field_definition: field_definition(i).as_json(options),
          value: f
        }
      end

      {
        definition: definition.as_json(options),
        fid: fid,
        field_count: field_count,
        fields: fields_with_nested_json,
        geometry: geometry ? geometry.as_json(options) : nil,
        geometry_field_count: geometry_field_count,
        geometry_field_definition: each_geometry_field_definition.map { |gfd| gfd.as_json(options) },
        style_string: style_string,
        style_table: style_table ? style_table.as_json(options) : nil
      }
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end
  end
end