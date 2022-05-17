# typed: strict

require "sorbet-runtime"

if ENV["RAILS_ENV"] == "production"
  sorbet_error_handler = lambda do |error, *_|
    Rails.logger.info "SORBET ERROR: #{error.message}"
  end

  # Suppresses errors caused by T.cast, T.let, T.must, etc.
  T::Configuration.inline_type_error_handler = sorbet_error_handler

  # Suppresses errors caused by incorrect parameter ordering
  T::Configuration.sig_validation_error_handler = sorbet_error_handler
end
