# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `Clearance::SessionsController`.
# Please instead update this file by running `bin/tapioca dsl Clearance::SessionsController`.

class Clearance::SessionsController
  sig { returns(HelperProxy) }
  def helpers; end

  module HelperMethods
    include ::ActionController::Base::HelperMethods
    include ::ApplicationHelper
    include ::DynamicErrorsHelper
    include ::OwnersHelper
    include ::PagesHelper
    include ::RubygemsHelper
    include ::SearchesHelper
    include ::UsersHelper
    include ::ActiveSupport::NumberHelper

    sig { returns(T.untyped) }
    def current_user; end

    sig { returns(T.untyped) }
    def signed_in?; end

    sig { returns(T.untyped) }
    def signed_out?; end
  end

  class HelperProxy < ::ActionView::Base
    include HelperMethods
  end
end
