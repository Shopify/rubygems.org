require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include OauthHelpers
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  # TODO: remove once https://github.com/rails/rails/pull/47117 is released
  Selenium::WebDriver.logger.ignore(:capabilities)

  Capybara.register_driver :fake_safari do |app|
    driver = Capybara::RackTest::Driver.new(app,
      headers: { "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3) AppleWebKit/605.1.15 (KHTML, like Gecko)
         Version/16.4 Safari/605.1.15" })

    # Rails SystemTests automatically call save_screenshot on Capybara drivers (except RackTest::Driver).
    # Rails doesn't recognize :fake_safari as being RackTest::Driver because it matches using
    # the driver name, not the class. Hence we need to provide a dummy method to avoid a NoMethodError.
    # See: https://github.com/rails/rails/blob/bccf42baf877774f7f8cd3a7a41aa974af5b9939/actionpack/lib/action_dispatch/system_testing/test_helpers/screenshot_helper.rb#L140-L142

    driver.class.send(:define_method, "save_screenshot", ->(_) {})

    driver
  end
end
