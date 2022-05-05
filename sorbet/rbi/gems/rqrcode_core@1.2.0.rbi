# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `rqrcode_core` gem.
# Please instead update this file by running `bin/tapioca gem rqrcode_core`.

module RQRCodeCore; end
RQRCodeCore::ALPHANUMERIC = T.let(T.unsafe(nil), Array)
RQRCodeCore::NUMERIC = T.let(T.unsafe(nil), Array)

class RQRCodeCore::QR8bitByte
  # @return [QR8bitByte] a new instance of QR8bitByte
  def initialize(data); end

  def write(buffer); end
end

class RQRCodeCore::QRAlphanumeric
  # @return [QRAlphanumeric] a new instance of QRAlphanumeric
  def initialize(data); end

  def write(buffer); end

  class << self
    # @return [Boolean]
    def valid_data?(data); end
  end
end

class RQRCodeCore::QRBitBuffer
  # @return [QRBitBuffer] a new instance of QRBitBuffer
  def initialize(version); end

  def alphanumeric_encoding_start(length); end

  # Returns the value of attribute buffer.
  def buffer; end

  def byte_encoding_start(length); end
  def end_of_message(max_data_bits); end
  def get(index); end
  def get_length_in_bits; end
  def numeric_encoding_start(length); end
  def pad_until(prefered_size); end
  def put(num, length); end
  def put_bit(bit); end
end

RQRCodeCore::QRBitBuffer::PAD0 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRBitBuffer::PAD1 = T.let(T.unsafe(nil), Integer)

# == Creation
#
# QRCode objects expect only one required constructor parameter
# and an optional hash of any other. Here's a few examples:
#
#  qr = RQRCodeCore::QRCode.new('hello world')
#  qr = RQRCodeCore::QRCode.new('hello world', size: 1, level: :m, mode: :alphanumeric)
class RQRCodeCore::QRCode
  extend ::Gem::Deprecate

  # Expects a string or array (for multi-segment encoding) to be parsed in, other args are optional
  #
  #   # data - the string, QRSegment or array of Hashes (with data:, mode: keys) you wish to encode
  #   # size - the size (Integer) of the QR Code (defaults to smallest size needed to encode the data)
  #   # max_size - the max_size (Integer) of the QR Code (default RQRCodeCore::QRUtil.max_size)
  #   # level - the error correction level, can be:
  #      * Level :l 7%  of code can be restored
  #      * Level :m 15% of code can be restored
  #      * Level :q 25% of code can be restored
  #      * Level :h 30% of code can be restored (default :h)
  #   # mode - the mode of the QR Code (defaults to alphanumeric or byte_8bit, depending on the input data, only used when data is a string):
  #      * :number
  #      * :alphanumeric
  #      * :byte_8bit
  #      * :kanji
  #
  #   qr = RQRCodeCore::QRCode.new('hello world', size: 1, level: :m, mode: :alphanumeric)
  #   segment_qr = QRCodeCore::QRCode.new({ data: 'foo', mode: :byte_8bit })
  #   multi_qr = RQRCodeCore::QRCode.new([{ data: 'foo', mode: :byte_8bit }, { data: 'bar1', mode: :alphanumeric }])
  #
  # @return [QRCode] a new instance of QRCode
  def initialize(data, *args); end

  def _deprecated_dark?(row, col); end

  # <tt>checked?</tt> is called with a +col+ and +row+ parameter. This will
  # return true or false based on whether that coordinate exists in the
  # matrix returned. It would normally be called while iterating through
  # <tt>modules</tt>. A simple example would be:
  #
  #  instance.checked?( 10, 10 ) => true
  #
  # @return [Boolean]
  def checked?(row, col); end

  # <tt>checked?</tt> is called with a +col+ and +row+ parameter. This will
  # return true or false based on whether that coordinate exists in the
  # matrix returned. It would normally be called while iterating through
  # <tt>modules</tt>. A simple example would be:
  #
  #  instance.checked?( 10, 10 ) => true
  #
  # @return [Boolean]
  def dark?(*args, **_arg1, &block); end

  # Return a symbol for current error connection level
  def error_correction_level; end

  # Public overide as default inspect is very verbose
  #
  #  RQRCodeCore::QRCode.new('my string to generate', size: 4, level: :h)
  #  => QRCodeCore: @data='my string to generate', @error_correct_level=2, @version=4, @module_count=33
  def inspect; end

  # Return a symbol in QRMODE.keys for current mode used
  def mode; end

  # Returns the value of attribute module_count.
  def module_count; end

  # Returns the value of attribute modules.
  def modules; end

  # Return true if this QR Code includes multiple encoded segments
  #
  # @return [Boolean]
  def multi_segment?; end

  # This is a public method that returns the QR Code you have
  # generated as a string. It will not be able to be read
  # in this format by a QR Code reader, but will give you an
  # idea if the final outout. It takes two optional args
  # +:dark+ and +:light+ which are there for you to choose
  # how the output looks. Here's an example of it's use:
  #
  #  instance.to_s =>
  #  xxxxxxx x  x x   x x  xx  xxxxxxx
  #  x     x  xxx  xxxxxx xxx  x     x
  #  x xxx x  xxxxx x       xx x xxx x
  #
  #  instance.to_s( dark: 'E', light: 'Q' ) =>
  #  EEEEEEEQEQQEQEQQQEQEQQEEQQEEEEEEE
  #  EQQQQQEQQEEEQQEEEEEEQEEEQQEQQQQQE
  #  EQEEEQEQQEEEEEQEQQQQQQQEEQEQEEEQE
  def to_s(*args); end

  # Returns the value of attribute version.
  def version; end

  protected

  def make; end

  private

  def extract_options!(arr); end
  def get_best_mask_pattern; end
  def make_impl(test, mask_pattern); end
  def map_data(data, mask_pattern); end

  # @raise [QRCodeRunTimeError]
  def minimum_version(limit: T.unsafe(nil), version: T.unsafe(nil)); end

  def place_format_info(test, mask_pattern); end
  def place_position_adjust_pattern; end
  def place_position_probe_pattern(row, col); end
  def place_timing_pattern; end
  def place_version_info(test); end
  def prepare_common_patterns; end

  class << self
    def count_max_data_bits(rs_blocks); end
    def create_bytes(buffer, rs_blocks); end
    def create_data(version, error_correct_level, data_list); end
  end
end

# StandardErrors
class RQRCodeCore::QRCodeArgumentError < ::ArgumentError; end

class RQRCodeCore::QRCodeRunTimeError < ::RuntimeError; end
RQRCodeCore::QRERRORCORRECTLEVEL = T.let(T.unsafe(nil), Hash)
RQRCodeCore::QRFORMATINFOLENGTH = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRMASKCOMPUTATIONS = T.let(T.unsafe(nil), Array)
RQRCodeCore::QRMASKPATTERN = T.let(T.unsafe(nil), Hash)

# http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable1-e.html
# http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable2-e.html
# http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable3-e.html
# http://web.archive.org/web/20110710094955/http://www.denso-wave.com/qrcode/vertable4-e.html
RQRCodeCore::QRMAXBITS = T.let(T.unsafe(nil), Hash)

RQRCodeCore::QRMODE = T.let(T.unsafe(nil), Hash)
RQRCodeCore::QRMODE_NAME = T.let(T.unsafe(nil), Hash)

class RQRCodeCore::QRMath
  class << self
    def gexp(n); end

    # @raise [QRCodeRunTimeError]
    def glog(n); end
  end
end

RQRCodeCore::QRMath::EXP_TABLE = T.let(T.unsafe(nil), Array)
RQRCodeCore::QRMath::LOG_TABLE = T.let(T.unsafe(nil), Array)

class RQRCodeCore::QRMulti
  # @return [QRMulti] a new instance of QRMulti
  def initialize(data); end

  def write(buffer); end
end

class RQRCodeCore::QRNumeric
  # @raise [QRCodeArgumentError]
  # @return [QRNumeric] a new instance of QRNumeric
  def initialize(data); end

  def write(buffer); end

  private

  def get_bit_length(length); end
  def get_code(chars); end

  class << self
    # @return [Boolean]
    def valid_data?(data); end
  end
end

RQRCodeCore::QRNumeric::NUMBER_LENGTH = T.let(T.unsafe(nil), Hash)
RQRCodeCore::QRPOSITIONPATTERNLENGTH = T.let(T.unsafe(nil), Integer)

class RQRCodeCore::QRPolynomial
  # @raise [QRCodeRunTimeError]
  # @return [QRPolynomial] a new instance of QRPolynomial
  def initialize(num, shift); end

  def get(index); end
  def get_length; end
  def mod(e); end
  def multiply(e); end
end

class RQRCodeCore::QRRSBlock
  # @return [QRRSBlock] a new instance of QRRSBlock
  def initialize(total_count, data_count); end

  # Returns the value of attribute data_count.
  def data_count; end

  # Returns the value of attribute total_count.
  def total_count; end

  class << self
    def get_rs_block_table(version, error_correct_level); end
    def get_rs_blocks(version, error_correct_level); end
  end
end

# http://www.thonky.com/qr-code-tutorial/error-correction-table/
RQRCodeCore::QRRSBlock::RS_BLOCK_TABLE = T.let(T.unsafe(nil), Array)

class RQRCodeCore::QRSegment
  # @return [QRSegment] a new instance of QRSegment
  def initialize(data:, mode: T.unsafe(nil)); end

  def content_size; end

  # Returns the value of attribute data.
  def data; end

  def header_size(version); end

  # Returns the value of attribute mode.
  def mode; end

  def size(version); end
  def writer; end

  private

  def data_length; end
end

class RQRCodeCore::QRUtil
  class << self
    def demerit_points_1_same_color(modules); end
    def demerit_points_2_full_blocks(modules); end
    def demerit_points_3_dangerous_patterns(modules); end
    def demerit_points_4_dark_ratio(modules); end
    def get_bch_digit(data); end
    def get_bch_format_info(data); end
    def get_bch_version(data); end
    def get_error_correct_polynomial(error_correct_length); end
    def get_length_in_bits(mode, version); end
    def get_lost_points(modules); end
    def get_mask(mask_pattern, i, j); end
    def get_pattern_positions(version); end
    def max_size; end
    def rszf(num, count); end
  end
end

RQRCodeCore::QRUtil::BITS_FOR_MODE = T.let(T.unsafe(nil), Hash)
RQRCodeCore::QRUtil::DEMERIT_POINTS_1 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::DEMERIT_POINTS_2 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::DEMERIT_POINTS_3 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::DEMERIT_POINTS_4 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::G15 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::G15_MASK = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::G18 = T.let(T.unsafe(nil), Integer)
RQRCodeCore::QRUtil::PATTERN_POSITION_TABLE = T.let(T.unsafe(nil), Array)
RQRCodeCore::VERSION = T.let(T.unsafe(nil), String)
