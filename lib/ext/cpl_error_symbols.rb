require_relative '../ffi-gdal/exceptions'


class ::Symbol

  # When FFI interfaces with a GDAL CPLError, it returns a Symbol that
  # maps to the CPLErr enum (see GDAL's cpl_error.h or cpl_error.rb docs). Since
  # many of the GDAL C API's functions return these symbols _and_ because the
  # symbols have some functional implications, this wrapping here is simply for
  # returning Ruby-esque values when the GDAL API returns one of these symbols.
  #
  # The optional params let you override behavior.  Passing in a block instead
  # will call the block.  Ex.
  #
  #   cpl_err = GDALCopyDatasetFiles(@gdal_driver_handle, new_name, old_name)
  #   cpl_err.to_ruby      # returns the default value
  #   cpl_err.to_ruby { raise 'Crap!' }
  def to_ruby(none: true, debug: true, warning: false, failure: nil, fatal: nil)
    return yield if block_given?

    case self
    when :CE_None then none
    when :CE_Debug then debug
    when :CE_Warning then warning
    when :CE_Failure 
      failure.nil? ? (raise CPLErrFailure) : failure
    when :CE_Fatal
      fatal.nil? ? (raise CPLErrFailure) : fatal
    end
  end
end
