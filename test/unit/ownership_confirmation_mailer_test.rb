require "test_helper"

class OwnershipConfirmationMailerTest < ActiveSupport::TestCase
  context "sending mail for ownership confirmation" do
    setup do
      @ownership = create(:ownership)
      create(:ownership_request, rubygem: @ownership.rubygem, created_at: 1.hour.ago)
      Delayed::Job.enqueue(OwnershipConfirmationMailer.new(@ownership.id))
      Delayed::Worker.new.work_off
    end

    should "send mail to owners" do
      refute_empty ActionMailer::Base.deliveries
      email = ActionMailer::Base.deliveries.last
      assert_equal [@ownership.user.email], email.to
      assert_equal ["no-reply@mailer.rubygems.org"], email.from
      assert_equal "Please confirm the ownership of #{@ownership.rubygem.name} gem on RubyGems.org", email.subject
      assert_match "You were added as an owner", email.text_part.body.to_s
    end
  end
end
