# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `elasticsearch-rails` gem.
# Please instead update this file by running `bin/tapioca gem elasticsearch-rails`.

module Elasticsearch; end
module Elasticsearch::Rails; end

# This module adds support for displaying statistics about search duration in the Rails application log
# by integrating with the `ActiveSupport::Notifications` framework and `ActionController` logger.
#
# == Usage
#
# Require the component in your `application.rb` file:
#
#     require 'elasticsearch/rails/instrumentation'
#
# You should see an output like this in your application log in development environment:
#
#     Article Search (321.3ms) { index: "articles", type: "article", body: { query: ... } }
#
# Also, the total duration of the request to Elasticsearch is displayed in the Rails request breakdown:
#
#     Completed 200 OK in 615ms (Views: 230.9ms | ActiveRecord: 0.0ms | Elasticsearch: 321.3ms)
#
# @note The displayed duration includes the HTTP transfer -- the time it took Elasticsearch
#   to process your request is available in the `response.took` property.
# @see Elasticsearch::Rails::Instrumentation::Publishers
# @see Elasticsearch::Rails::Instrumentation::Railtie
# @see http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html
module Elasticsearch::Rails::Instrumentation; end

module Elasticsearch::Rails::Instrumentation::Publishers; end

# Wraps the `SearchRequest` methods to perform the instrumentation
#
# @see SearchRequest#execute_with_instrumentation!
# @see http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html
module Elasticsearch::Rails::Instrumentation::Publishers::SearchRequest
  # Wrap `Search#execute!` and perform instrumentation
  def execute_with_instrumentation!; end

  class << self
    # @private
    def included(base); end
  end
end

# Rails initializer class to require Elasticsearch::Rails::Instrumentation files,
# set up Elasticsearch::Model and hook into ActionController to display Elasticsearch-related duration
#
# @see http://edgeguides.rubyonrails.org/active_support_instrumentation.html
class Elasticsearch::Rails::Instrumentation::Railtie < ::Rails::Railtie; end

Elasticsearch::Rails::VERSION = T.let(T.unsafe(nil), String)
Elasticsearch::VERSION = T.let(T.unsafe(nil), String)
