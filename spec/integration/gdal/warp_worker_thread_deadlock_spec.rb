# frozen_string_literal: true

require "timeout"
require "tmpdir"
require "ffi-gdal"
require "gdal"

# Regression guard for the GDAL >= 3.11 warp worker-thread deadlock.
#
# GDAL's multi-threaded warp (NUM_THREADS > 1) reports warnings from worker threads. A freshly
# created raster is all zeros with no NoData set, so warping it with "-dstnodata 0" makes GDAL
# treat every valid 0 as a clash and emit "Value 0 in the source dataset has been changed to
# 1 ... to avoid being treated as NoData" -- from a worker thread. If ffi-gdal's *global* error
# handler is a Ruby callback, that report must run on FFI's callback-dispatcher thread, which
# needs the GVL. The calling Ruby thread holds the GVL while blocked inside the warp waiting on
# its workers, the workers block waiting for the callback, and the process deadlocks. GDAL 3.10
# reported from the calling thread, so it never surfaced.
#
# The fix installs GDAL's native C handler as the global handler (see
# GDAL::CPLErrorHandler::NATIVE_DEFAULT_HANDLER) and pushes the Ruby handler onto the main
# thread's thread-local stack, so worker threads never call into Ruby.
#
# The warp runs in a forked child so a regression surfaces as a detectable timeout instead of
# hanging the whole suite.
RSpec.describe "GDAL warp worker-thread deadlock", type: :integration do
  around do |example|
    Dir.mktmpdir do |dir|
      @source_path = File.join(dir, "all_zero_source.tif")
      create_all_zero_source(@source_path)
      example.run
    end
  end

  # An all-zero raster with no NoData: warping it with "-dstnodata 0" makes every pixel a
  # "valid 0" and triggers the worker-thread NoData warning that exposes the deadlock.
  def create_all_zero_source(path)
    dataset = GDAL::Driver.by_name("GTiff").create_dataset(path, 256, 256, band_count: 3, data_type: :GDT_Byte)
    dataset.projection = "EPSG:3857"

    geo_transform = GDAL::GeoTransform.new
    geo_transform.x_origin = -13_711_381.13
    geo_transform.pixel_width = 30.0
    geo_transform.y_origin = 5_583_672.44
    geo_transform.pixel_height = -30.0
    dataset.geo_transform = geo_transform

    dataset.close
  end

  # Runs a multi-threaded warp in a child process and returns whether it finished within the
  # timeout. A deadlock leaves the child hung, which the parent detects and kills.
  def warp_finishes_within?(seconds)
    pid = fork do
      Dir.mktmpdir do |dir|
        GDAL::Dataset.open(@source_path, "r") do |source|
          GDAL::Utils::Warp.perform(
            dst_dataset_path: File.join(dir, "out.tif"),
            src_datasets: [source],
            options: GDAL::Utils::Warp::Options.new(
              options: ["-multi", "-wo", "NUM_THREADS=8", "-dstnodata", "0", "-t_srs", "EPSG:4326", "-of", "GTiff"]
            )
          ).close
        end
      end
      exit!(0)
    end

    Timeout.timeout(seconds) do
      _pid, status = Process.waitpid2(pid)
      status.success?
    end
  rescue Timeout::Error
    Process.kill("KILL", pid)
    Process.waitpid(pid)
    false
  end

  it "materializes a multi-threaded warp without deadlocking" do
    skip "fork is unavailable on this platform" unless Process.respond_to?(:fork)

    expect(warp_finishes_within?(1)).to be(true)
  end
end
