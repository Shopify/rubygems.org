# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `gravtastic` gem.
# Please instead update this file by running `bin/tapioca gem gravtastic`.

module Gravtastic
  mixes_in_class_methods ::Gravtastic::StageOne

  class << self
    # Sets the model's default attributes. It is called when you use
    # `#gravtastic` in your model.
    def configure(model, *args, &blk); end

    # When you `include Gravtastic`, Ruby automatically calls this method
    # with the class you called it in. It allows us extend the class with the
    # `#gravtastic` method.
    def included(model); end

    # Returns the version of Gravtastic
    def version; end
  end
end

module Gravtastic::ClassMethods
  # Gravtastic abbreviates certain params so that it produces the smallest
  # possible URL. Every byte counts.
  def gravatar_abbreviations; end

  # Returns the value of attribute gravatar_defaults.
  def gravatar_defaults; end

  # Sets the attribute gravatar_defaults
  #
  # @param value the value to set the attribute gravatar_defaults to.
  def gravatar_defaults=(_arg0); end

  # Returns the value of attribute gravatar_source.
  def gravatar_source; end

  # Sets the attribute gravatar_source
  #
  # @param value the value to set the attribute gravatar_source to.
  def gravatar_source=(_arg0); end
end

class Gravtastic::Engine < ::Rails::Engine; end

module Gravtastic::InstanceMethods
  # The raw MD5 hash of the users' email. Gravatar is particularly tricky as
  # it downcases all emails. This is really the guts of the module,
  # everything else is just convenience.
  def gravatar_id; end

  # Constructs the full Gravatar url.
  def gravatar_url(options = T.unsafe(nil)); end

  private

  # Munges the ID and the filetype into one. Like "abc123.png"
  def gravatar_filename(filetype); end

  # Returns either Gravatar's secure hostname or not.
  def gravatar_hostname(secure); end

  # Creates a params hash like "?foo=bar" from a hash like {'foo' => 'bar'}.
  # The values are sorted so it produces deterministic output (and can
  # therefore be tested easily).
  def url_params_from_hash(hash); end
end

# We include Gravtastic in multiple stages. This is mainly so that if you
# include Gravastic in a superclass (something like `ActiveRecord::Base`)
# then it only adds the relevant methods to the classes which _actually_ use
# it.
module Gravtastic::StageOne
  def gravtastic(*args, &blk); end

  # All these aliases deal with previous bad design decisions. Let that be a
  # lesson, name things simply, try not to follow fads and try not to break
  # backwards compatibility.
  def gravtastic!(*args, &blk); end

  def has_gravatar(*args, &blk); end
  def is_gravtastic(*args, &blk); end
  def is_gravtastic!(*args, &blk); end
end

Gravtastic::VERSION = T.let(T.unsafe(nil), String)
