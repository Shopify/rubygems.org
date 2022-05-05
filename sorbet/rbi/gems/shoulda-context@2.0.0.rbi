# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `shoulda-context` gem.
# Please instead update this file by running `bin/tapioca gem shoulda-context`.

# Stolen straight from ActiveSupport
class Proc
  include ::MethodSource::SourceLocation::ProcExtensions
  include ::MethodSource::MethodExtensions

  def bind(object); end
end

module Shoulda
  class << self
    # Call autoload_macros when you want to load test macros automatically in a non-Rails
    # project (it's done automatically for Rails projects).
    # You don't need to specify ROOT/test/shoulda_macros explicitly. Your custom macros
    # are loaded automatically when you call autoload_macros.
    #
    # The first argument is the path to you application's root directory.
    # All following arguments are directories relative to your root, which contain
    # shoulda_macros subdirectories. These directories support the same kinds of globs as the
    # Dir class.
    #
    # Basic usage (from a test_helper):
    # Shoulda.autoload_macros(File.dirname(__FILE__) + '/..')
    # will load everything in
    # - your_app/test/shoulda_macros
    #
    # To load vendored macros as well:
    # Shoulda.autoload_macros(APP_ROOT, 'vendor/*')
    # will load everything in
    # - APP_ROOT/vendor/*/shoulda_macros
    # - APP_ROOT/test/shoulda_macros
    #
    # To load macros in an app with a vendor directory laid out like Rails':
    # Shoulda.autoload_macros(APP_ROOT, 'vendor/{plugins,gems}/*')
    # or
    # Shoulda.autoload_macros(APP_ROOT, 'vendor/plugins/*', 'vendor/gems/*')
    # will load everything in
    # - APP_ROOT/vendor/plugins/*/shoulda_macros
    # - APP_ROOT/vendor/gems/*/shoulda_macros
    # - APP_ROOT/test/shoulda_macros
    #
    # If you prefer to stick testing dependencies away from your production dependencies:
    # Shoulda.autoload_macros(APP_ROOT, 'vendor/*', 'test/vendor/*')
    # will load everything in
    # - APP_ROOT/vendor/*/shoulda_macros
    # - APP_ROOT/test/vendor/*/shoulda_macros
    # - APP_ROOT/test/shoulda_macros
    def autoload_macros(root, *dirs); end
  end
end

module Shoulda::Context
  class << self
    def add_context(context); end

    # @yield [_self]
    # @yieldparam _self [Shoulda::Context] the object that the method was called on
    def configure; end

    def contexts; end

    # Sets the attribute contexts
    #
    # @param value the value to set the attribute contexts to.
    def contexts=(_arg0); end

    def current_context; end
    def extend(mod); end
    def include(mod); end
    def remove_context; end
    def test_framework_test_cases; end
  end
end

module Shoulda::Context::Assertions
  # Asserts that the given matcher returns true when +target+ is passed to
  # #matches?
  def assert_accepts(matcher, target, options = T.unsafe(nil)); end

  # Asserts that the given collection contains item x.  If x is a regular expression, ensure that
  # at least one element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
  #
  #   assert_contains(['a', '1'], /\d/) => passes
  #   assert_contains(['a', '1'], 'a') => passes
  #   assert_contains(['a', '1'], /not there/) => fails
  def assert_contains(collection, x, extra_msg = T.unsafe(nil)); end

  # Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
  # none of the elements from the collection match x.
  def assert_does_not_contain(collection, x, extra_msg = T.unsafe(nil)); end

  # Asserts that the given matcher returns true when +target+ is passed to
  # #does_not_match? or false when +target+ is passed to #matches? if
  # #does_not_match? is not implemented
  def assert_rejects(matcher, target, options = T.unsafe(nil)); end

  # Asserts that two arrays contain the same elements, the same number of times.  Essentially ==, but unordered.
  #
  #   assert_same_elements([:a, :b, :c], [:c, :a, :b]) => passes)
  def assert_same_elements(a1, a2, msg = T.unsafe(nil)); end

  def safe_assert_block(message = T.unsafe(nil), &block); end
end

class Shoulda::Context::Context
  # @return [Context] a new instance of Context
  def initialize(name, parent, &blk); end

  # @return [Boolean]
  def am_subcontext?; end

  def build; end
  def build_test_name_from(should); end
  def context(name, &blk); end
  def create_test_from_should_hash(should); end
  def full_name; end
  def merge_block(&blk); end
  def method_missing(method, *args, &blk); end

  # my name
  def name; end

  # my name
  def name=(_arg0); end

  # may be another context, or the original test::unit class.
  def parent; end

  # may be another context, or the original test::unit class.
  def parent=(_arg0); end

  def print_should_eventuallys; end
  def run_all_setup_blocks(binding); end
  def run_all_teardown_blocks(binding); end
  def run_current_setup_blocks(binding); end
  def run_parent_setup_blocks(binding); end
  def setup(&blk); end

  # blocks given via setup methods
  def setup_blocks; end

  # blocks given via setup methods
  def setup_blocks=(_arg0); end

  def should(name_or_matcher, options = T.unsafe(nil), &blk); end
  def should_eventually(name, &blk); end

  # array of hashes representing the should eventually statements
  def should_eventuallys; end

  # array of hashes representing the should eventually statements
  def should_eventuallys=(_arg0); end

  def should_not(matcher); end

  # array of hashes representing the should statements
  def shoulds; end

  # array of hashes representing the should statements
  def shoulds=(_arg0); end

  # array of contexts nested under myself
  def subcontexts; end

  # array of contexts nested under myself
  def subcontexts=(_arg0); end

  def subject(&block); end

  # accessor with cache
  def subject_block; end

  # Sets the attribute subject_block
  #
  # @param value the value to set the attribute subject_block to.
  def subject_block=(_arg0); end

  def teardown(&blk); end

  # blocks given via teardown methods
  def teardown_blocks; end

  # blocks given via teardown methods
  def teardown_blocks=(_arg0); end

  def test_methods; end
  def test_name_prefix; end
  def test_unit_class; end
end

module Shoulda::Context::DSL
  include ::Shoulda::Context::Assertions
  include ::Shoulda::Context::DSL::InstanceMethods

  mixes_in_class_methods ::Shoulda::Context::DSL::ClassMethods

  class << self
    # @private
    def included(base); end
  end
end

module Shoulda::Context::DSL::ClassMethods
  # == Before statements
  #
  # Before statements are should statements that run before the current
  # context's setup. These are especially useful when setting expectations.
  #
  # === Example:
  #
  #  class UserControllerTest < Test::Unit::TestCase
  #    context "the index action" do
  #      setup do
  #        @users = [Factory(:user)]
  #        User.stubs(:find).returns(@users)
  #      end
  #
  #      context "on GET" do
  #        setup { get :index }
  #
  #        should respond_with(:success)
  #
  #        # runs before "get :index"
  #        before_should "find all users" do
  #          User.expects(:find).with(:all).returns(@users)
  #        end
  #      end
  #    end
  #  end
  def before_should(name, &blk); end

  # == Contexts
  #
  # A context block groups should statements under a common set of setup/teardown methods.
  # Context blocks can be arbitrarily nested, and can do wonders for improving the maintainability
  # and readability of your test code.
  #
  # A context block can contain setup, should, should_eventually, and teardown blocks.
  #
  #  class UserTest < Test::Unit::TestCase
  #    context "A User instance" do
  #      setup do
  #        @user = User.find(:first)
  #      end
  #
  #      should "return its full name"
  #        assert_equal 'John Doe', @user.full_name
  #      end
  #    end
  #  end
  #
  # This code will produce the method <tt>"test: A User instance should return its full name. "</tt>.
  #
  # Contexts may be nested.  Nested contexts run their setup blocks from out to in before each
  # should statement.  They then run their teardown blocks from in to out after each should statement.
  #
  #  class UserTest < Test::Unit::TestCase
  #    context "A User instance" do
  #      setup do
  #        @user = User.find(:first)
  #      end
  #
  #      should "return its full name"
  #        assert_equal 'John Doe', @user.full_name
  #      end
  #
  #      context "with a profile" do
  #        setup do
  #          @user.profile = Profile.find(:first)
  #        end
  #
  #        should "return true when sent :has_profile?"
  #          assert @user.has_profile?
  #        end
  #      end
  #    end
  #  end
  #
  # This code will produce the following methods
  # * <tt>"test: A User instance should return its full name. "</tt>
  # * <tt>"test: A User instance with a profile should return true when sent :has_profile?. "</tt>
  #
  # <b>Just like should statements, a context block can exist next to normal <tt>def test_the_old_way; end</tt>
  # tests</b>.  This means you do not have to fully commit to the context/should syntax in a test file.
  def context(name, &blk); end

  # Returns the class being tested, as determined by the test class name.
  #
  #   class UserTest; described_type; end
  #   # => User
  def described_type; end

  # == Should statements
  #
  # Should statements are just syntactic sugar over normal Test::Unit test
  # methods.  A should block contains all the normal code and assertions
  # you're used to seeing, with the added benefit that they can be wrapped
  # inside context blocks (see below).
  #
  # === Example:
  #
  #  class UserTest < Test::Unit::TestCase
  #
  #    def setup
  #      @user = User.new("John", "Doe")
  #    end
  #
  #    should "return its full name"
  #      assert_equal 'John Doe', @user.full_name
  #    end
  #
  #  end
  #
  # ...will produce the following test:
  # * <tt>"test: User should return its full name. "</tt>
  #
  # Note: The part before <tt>should</tt> in the test name is gleamed from the name of the Test::Unit class.
  #
  # Should statements can also take a Proc as a <tt>:before </tt>option.  This proc runs after any
  # parent context's setups but before the current context's setup.
  #
  # === Example:
  #
  #  context "Some context" do
  #    setup { puts("I run after the :before proc") }
  #
  #    should "run a :before proc", :before => lambda { puts("I run before the setup") }  do
  #      assert true
  #    end
  #  end
  #
  # Should statements can also wrap matchers, making virtually any matcher
  # usable in a macro style. The matcher's description is used to generate a
  # test name and failure message, and the test will pass if the matcher
  # matches the subject.
  #
  # === Example:
  #
  #   should validate_presence_of(:first_name).with_message(/gotta be there/)
  def should(name_or_matcher, options = T.unsafe(nil), &blk); end

  # Just like should, but never runs, and instead prints an 'X' in the Test::Unit output.
  def should_eventually(name, options = T.unsafe(nil), &blk); end

  # Allows negative tests using matchers. The matcher's description is used
  # to generate a test name and negative failure message, and the test will
  # pass unless the matcher matches the subject.
  #
  # === Example:
  #
  #   should_not set_the_flash
  def should_not(matcher); end

  # Sets the return value of the subject instance method:
  #
  #   class UserTest < Test::Unit::TestCase
  #     subject { User.first }
  #
  #     # uses the existing user
  #     should validate_uniqueness_of(:email)
  #   end
  def subject(&block); end

  def subject_block; end
end

module Shoulda::Context::DSL::InstanceMethods
  def get_instance_of(object_or_klass); end
  def instance_variable_name_for(klass); end

  # Returns an instance of the class under test.
  #
  #   class UserTest
  #     should "be a user" do
  #       assert_kind_of User, subject # passes
  #     end
  #   end
  #
  # The subject can be explicitly set using the subject class method:
  #
  #   class UserTest
  #     subject { User.first }
  #     should "be an existing user" do
  #       assert !subject.new_record? # uses the first user
  #     end
  #   end
  #
  # The subject is used by all macros that require an instance of the class
  # being tested.
  def subject; end

  def subject_block; end

  private

  def construct_subject; end
end

class Shoulda::Context::DuplicateTestError < ::RuntimeError; end
class Shoulda::Context::Railtie < ::Rails::Railtie; end

module Shoulda::Context::TestFrameworkDetection
  class << self
    def detected_test_framework_test_cases; end
    def possible_test_frameworks; end
    def resolve_framework(future_framework); end
    def test_framework_test_cases; end
  end
end

Shoulda::Context::VERSION = T.let(T.unsafe(nil), String)
Shoulda::VERSION = T.let(T.unsafe(nil), String)
