# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `OwnersMailer`.
# Please instead update this file by running `bin/tapioca dsl OwnersMailer`.

class OwnersMailer
  class << self
    sig { params(ownership: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def confirmation_status(ownership); end

    sig { params(user: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def mfa_status(user); end

    sig { params(rubygem_id: T.untyped, user_id: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def new_ownership_requests(rubygem_id, user_id); end

    sig do
      params(
        user_id: T.untyped,
        owner_id: T.untyped,
        authorizer_id: T.untyped,
        gem_id: T.untyped
      ).returns(::ActionMailer::MessageDelivery)
    end
    def owner_added(user_id, owner_id, authorizer_id, gem_id); end

    sig { params(owner: T.untyped, user: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def owner_i18n_key(owner, user); end

    sig do
      params(
        user_id: T.untyped,
        remover_id: T.untyped,
        gem_id: T.untyped
      ).returns(::ActionMailer::MessageDelivery)
    end
    def owner_removed(user_id, remover_id, gem_id); end

    sig { params(ownership: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def ownership_confirmation(ownership); end

    sig { params(ownership_request_id: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def ownership_request_approved(ownership_request_id); end

    sig { params(ownership_request_id: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def ownership_request_closed(ownership_request_id); end

    sig { returns(::ActionMailer::MessageDelivery) }
    def roadie_options; end

    sig { params(text: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def sanitize_note(text); end
  end
end
