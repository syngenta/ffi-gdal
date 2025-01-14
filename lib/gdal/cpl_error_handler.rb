# frozen_string_literal: true

module GDAL
  # This is used to override GDAL's built-in error handling.  By default, GDAL
  # only logs errors to STDOUT, which doesn't allow a whole lot of flexibility.
  # This maps GDAL's errors to either standard Ruby exceptions or new exceptions
  # defined in this gem.  Doing so also lets ffi-gdal users rescue these
  # exceptions, which is beneficial for obvious reasons.
  class CPLErrorHandler
    include GDAL::Logger

    # NOTE: Error codes are defined in https://gdal.org/doxygen/cpl__error_8h_source.html
    CPLE_MAP = [
      { cple: :CPLE_None,                     exception: nil }.freeze,
      { cple: :CPLE_AppDefined,               exception: GDAL::Error }.freeze,
      { cple: :CPLE_OutOfMemory,              exception: ::NoMemoryError }.freeze,
      { cple: :CPLE_FileIO,                   exception: ::IOError }.freeze,
      { cple: :CPLE_OpenFailed,               exception: GDAL::OpenFailure }.freeze,
      { cple: :CPLE_IllegalArg,               exception: ::ArgumentError }.freeze,
      { cple: :CPLE_NotSupported,             exception: GDAL::UnsupportedOperation }.freeze,
      { cple: :CPLE_AssertionFailed,          exception: ::RuntimeError }.freeze,
      { cple: :CPLE_NoWriteAccess,            exception: GDAL::NoWriteAccess }.freeze,
      { cple: :CPLE_UserInterrupt,            exception: ::Interrupt }.freeze,
      { cple: :CPLE_ObjectNull,               exception: GDAL::NullObject }.freeze,
      { cple: :CPLE_HttpResponse,             exception: GDAL::HttpResponse }.freeze,
      { cple: :CPLE_AWSBucketNotFound,        exception: GDAL::AWSBucketNotFound }.freeze,
      { cple: :CPLE_AWSObjectNotFound,        exception: GDAL::AWSObjectNotFound }.freeze,
      { cple: :CPLE_AWSAccessDenied,          exception: GDAL::AWSAccessDenied }.freeze,
      { cple: :CPLE_AWSInvalidCredentials,    exception: GDAL::AWSInvalidCredentials }.freeze,
      { cple: :CPLE_AWSSignatureDoesNotMatch, exception: GDAL::AWSSignatureDoesNotMatch }.freeze
    ].freeze
    FALLBACK_CPLE_EXCEPTION = { exception: GDAL::Error }.freeze

    FAIL_PROC = lambda do |exception, message|
      ex = exception ? exception.new(message) : GDAL::Error.new(message)
      ex.set_backtrace(caller(3))

      raise(ex)
    end

    SUCCESS_PROC = proc { true }

    # @return [Proc]
    def self.handle_error
      new.handler_lambda
    end

    # @param message [String] Exception message if the block returns something
    #   that should cause a raise.
    # @raise [GDAL::Error]
    def self.manually_handle(message)
      cpl_err = yield

      case cpl_err
      when :CE_Fatal, :CE_Failure then raise GDAL::Error, message
      end
    end

    # @return [Proc]
    attr_accessor :on_none

    # @return [Proc]
    attr_accessor :on_debug

    # @return [Proc]
    attr_accessor :on_warning

    # @return [Proc]
    attr_accessor :on_failure

    # @return [Proc]
    attr_accessor :on_fatal

    def initialize
      @on_none = SUCCESS_PROC

      @on_debug = lambda do |_, message|
        logger.debug(message)
        true
      end

      @on_warning = lambda do |_, message|
        logger.warn(message)
        true
      end

      @on_failure = FAIL_PROC
      @on_fatal = FAIL_PROC
    end

    # Looks up the error class then calls the appropriate +on_+ proc, thus
    # handling various error/non-error scenarios.  More info here:
    # http://www.gdal.org/cpl__error_8h.html#a74d0e649d58180e621540bf73b58e4a2.
    #
    # @return [Proc] A lambda that adheres to the CPL Error interface.
    def handler_lambda
      @handler_lambda ||= lambda do |error_class, error_number, message|
        r = result(error_class, error_number, message)
        FFI::CPL::Error.CPLErrorReset

        r
      end
    end

    # Use this when you want to override the default event handling.  For
    # example, you may want to return a value in the case of a :CE_Warning.
    # To do so, you need to create a new ErrorHandler object, assign a new
    # Proc by calling #on_warning=, then call this method with your wrapped
    # CPLErr-returning function in a block.  That might look something like:
    #
    #     handler = GDAL::ErrorHandler.new
    #     handler.on_warning = -> { warn 'Uh oh!'; return Array.new }
    #     handler.custom_handle do
    #       FFI::GDAL.DoSomeStuff()
    #     end
    #
    # After this code gets called, error handling will return to normal.
    def custom_handle
      FFI::CPL::Error.CPLPushErrorHandler(handler_lambda)
      yield

      msg, ptr = FFI::CPL::Error.CPLGetLastErrorMsg
      ptr.autorelease = false

      r = result(FFI::CPL::Error.CPLGetLastErrorType,
                 FFI::CPL::Error.CPLGetLastErrorNo,
                 msg)
      FFI::CPL::Error.CPLErrorReset
      FFI::CPL::Error.CPLPopErrorHandler

      r
    end

    private

    # @return Whatever the Proc evaluates.
    def result(error_class, error_number, message)
      error_class_map(error_class).call(
        CPLE_MAP.fetch(error_number, FALLBACK_CPLE_EXCEPTION).fetch(:exception),
        message
      )
    end

    def error_class_map(error_class)
      {
        CE_None: @on_none,
        CE_Debug: @on_debug,
        CE_Warning: @on_warning,
        CE_Failure: @on_failure,
        CE_Fatal: @on_fatal
      }[error_class]
    end
  end
end
