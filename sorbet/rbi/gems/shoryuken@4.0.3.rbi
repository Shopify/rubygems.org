# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `shoryuken` gem.
# Please instead update this file by running `bin/tapioca gem shoryuken`.

module ActiveJob
  extend ::ActiveSupport::Autoload

  class << self
    # Returns the version of the currently loaded Active Job as a <tt>Gem::Version</tt>
    def gem_version; end

    # Returns the version of the currently loaded Active Job as a <tt>Gem::Version</tt>
    def version; end
  end
end

# == Active Job adapters
#
# Active Job has adapters for the following queuing backends:
#
# * {Backburner}[https://github.com/nesquena/backburner]
# * {Delayed Job}[https://github.com/collectiveidea/delayed_job]
# * {Que}[https://github.com/chanks/que]
# * {queue_classic}[https://github.com/QueueClassic/queue_classic]
# * {Resque}[https://github.com/resque/resque]
# * {Sidekiq}[https://sidekiq.org]
# * {Sneakers}[https://github.com/jondot/sneakers]
# * {Sucker Punch}[https://github.com/brandonhilkert/sucker_punch]
# * {Active Job Async Job}[https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/AsyncAdapter.html]
# * {Active Job Inline}[https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters/InlineAdapter.html]
# * Please Note: We are not accepting pull requests for new adapters. See the {README}[link:files/activejob/README_md.html] for more details.
#
# === Backends Features
#
#   |                   | Async | Queues | Delayed    | Priorities | Timeout | Retries |
#   |-------------------|-------|--------|------------|------------|---------|---------|
#   | Backburner        | Yes   | Yes    | Yes        | Yes        | Job     | Global  |
#   | Delayed Job       | Yes   | Yes    | Yes        | Job        | Global  | Global  |
#   | Que               | Yes   | Yes    | Yes        | Job        | No      | Job     |
#   | queue_classic     | Yes   | Yes    | Yes*       | No         | No      | No      |
#   | Resque            | Yes   | Yes    | Yes (Gem)  | Queue      | Global  | Yes     |
#   | Sidekiq           | Yes   | Yes    | Yes        | Queue      | No      | Job     |
#   | Sneakers          | Yes   | Yes    | No         | Queue      | Queue   | No      |
#   | Sucker Punch      | Yes   | Yes    | Yes        | No         | No      | No      |
#   | Active Job Async  | Yes   | Yes    | Yes        | No         | No      | No      |
#   | Active Job Inline | No    | Yes    | N/A        | N/A        | N/A     | N/A     |
#
# ==== Async
#
# Yes: The Queue Adapter has the ability to run the job in a non-blocking manner.
# It either runs on a separate or forked process, or on a different thread.
#
# No: The job is run in the same process.
#
# ==== Queues
#
# Yes: Jobs may set which queue they are run in with queue_as or by using the set
# method.
#
# ==== Delayed
#
# Yes: The adapter will run the job in the future through perform_later.
#
# (Gem): An additional gem is required to use perform_later with this adapter.
#
# No: The adapter will run jobs at the next opportunity and cannot use perform_later.
#
# N/A: The adapter does not support queuing.
#
# NOTE:
# queue_classic supports job scheduling since version 3.1.
# For older versions you can use the queue_classic-later gem.
#
# ==== Priorities
#
# The order in which jobs are processed can be configured differently depending
# on the adapter.
#
# Job: Any class inheriting from the adapter may set the priority on the job
# object relative to other jobs.
#
# Queue: The adapter can set the priority for job queues, when setting a queue
# with Active Job this will be respected.
#
# Yes: Allows the priority to be set on the job object, at the queue level or
# as default configuration option.
#
# No: The adapter does not allow the priority of jobs to be configured.
#
# N/A: The adapter does not support queuing, and therefore sorting them.
#
# ==== Timeout
#
# When a job will stop after the allotted time.
#
# Job: The timeout can be set for each instance of the job class.
#
# Queue: The timeout is set for all jobs on the queue.
#
# Global: The adapter is configured that all jobs have a maximum run time.
#
# No: The adapter does not allow the timeout of jobs to be configured.
#
# N/A: This adapter does not run in a separate process, and therefore timeout
# is unsupported.
#
# ==== Retries
#
# Job: The number of retries can be set per instance of the job class.
#
# Yes: The Number of retries can be configured globally, for each instance or
# on the queue. This adapter may also present failed instances of the job class
# that can be restarted.
#
# Global: The adapter has a global number of retries.
#
# No: The adapter does not allow the number of retries to be configured.
#
# N/A: The adapter does not run in a separate process, and therefore doesn't
# support retries.
#
# === Async and Inline Queue Adapters
#
# Active Job has two built-in queue adapters intended for development and
# testing: +:async+ and +:inline+.
module ActiveJob::QueueAdapters
  extend ::ActiveSupport::Autoload

  class << self
    # Returns adapter for specified name.
    #
    #   ActiveJob::QueueAdapters.lookup(:sidekiq)
    #   # => ActiveJob::QueueAdapters::SidekiqAdapter
    def lookup(name); end
  end
end

# == Shoryuken adapter for Active Job
#
# Shoryuken ("sho-ryu-ken") is a super-efficient AWS SQS thread based message processor.
#
# Read more about Shoryuken {here}[https://github.com/phstc/shoryuken].
#
# To use Shoryuken set the queue_adapter config to +:shoryuken+.
#
#   Rails.application.config.active_job.queue_adapter = :shoryuken
class ActiveJob::QueueAdapters::ShoryukenAdapter
  def enqueue(job, options = T.unsafe(nil)); end
  def enqueue_at(job, timestamp); end

  private

  def calculate_delay(timestamp); end
  def message(queue, job, options = T.unsafe(nil)); end
  def message_attributes; end
  def register_worker!(job); end

  class << self
    def enqueue(job); end
    def enqueue_at(job, timestamp); end
    def instance; end
  end
end

class ActiveJob::QueueAdapters::ShoryukenAdapter::JobWrapper
  include ::Shoryuken::Worker
  extend ::Shoryuken::Worker::ClassMethods

  def perform(_sqs_msg, hash); end
  def shoryuken_options_hash; end
  def shoryuken_options_hash=(_arg0); end

  class << self
    def shoryuken_options_hash; end
    def shoryuken_options_hash=(val); end
  end
end

module Shoryuken
  extend ::SingleForwardable

  class << self
    def active_job?(*args, **_arg1, &block); end
    def active_job_queue_name_prefixing(*args, **_arg1, &block); end
    def active_job_queue_name_prefixing=(*args, **_arg1, &block); end
    def add_group(*args, **_arg1, &block); end
    def add_queue(*args, **_arg1, &block); end
    def cache_visibility_timeout=(*args, **_arg1, &block); end
    def cache_visibility_timeout?(*args, **_arg1, &block); end
    def client_middleware(*args, **_arg1, &block); end
    def configure_client(*args, **_arg1, &block); end
    def configure_server(*args, **_arg1, &block); end
    def default_worker_options(*args, **_arg1, &block); end
    def default_worker_options=(*args, **_arg1, &block); end
    def groups(*args, **_arg1, &block); end
    def launcher_executor(*args, **_arg1, &block); end
    def launcher_executor=(*args, **_arg1, &block); end
    def logger(*args, **_arg1, &block); end
    def on(*args, **_arg1, &block); end
    def on_start(*args, **_arg1, &block); end
    def on_stop(*args, **_arg1, &block); end
    def options(*args, **_arg1, &block); end
    def polling_strategy(*args, **_arg1, &block); end
    def register_worker(*args, **_arg1, &block); end
    def server?(*args, **_arg1, &block); end
    def server_middleware(*args, **_arg1, &block); end
    def sqs_client(*args, **_arg1, &block); end
    def sqs_client=(*args, **_arg1, &block); end
    def sqs_client_receive_message_opts(*args, **_arg1, &block); end
    def sqs_client_receive_message_opts=(*args, **_arg1, &block); end
    def start_callback(*args, **_arg1, &block); end
    def start_callback=(*args, **_arg1, &block); end
    def stop_callback(*args, **_arg1, &block); end
    def stop_callback=(*args, **_arg1, &block); end
    def ungrouped_queues(*args, **_arg1, &block); end
    def worker_executor(*args, **_arg1, &block); end
    def worker_executor=(*args, **_arg1, &block); end
    def worker_registry(*args, **_arg1, &block); end
    def worker_registry=(*args, **_arg1, &block); end
  end
end

class Shoryuken::BodyParser
  class << self
    def parse(worker_class, sqs_msg); end
  end
end

class Shoryuken::Client
  class << self
    def queues(name); end
    def sqs; end
    def sqs=(sqs); end
  end
end

class Shoryuken::DefaultWorkerRegistry < ::Shoryuken::WorkerRegistry
  # @return [DefaultWorkerRegistry] a new instance of DefaultWorkerRegistry
  def initialize; end

  # @return [Boolean]
  def batch_receive_messages?(queue); end

  def clear; end
  def fetch_worker(queue, message); end
  def queues; end
  def register_worker(queue, clazz); end
  def workers(queue); end
end

class Shoryuken::EnvironmentLoader
  # @return [EnvironmentLoader] a new instance of EnvironmentLoader
  def initialize(options); end

  def load; end

  # Returns the value of attribute options.
  def options; end

  def setup_options; end

  private

  def config_file_options; end
  def initialize_logger; end
  def initialize_options; end
  def load_rails; end
  def merge_cli_defined_queues; end
  def parse_queue(queue, weight, group); end
  def parse_queues; end
  def prefix_active_job_queue_name(queue_name, weight); end
  def prefix_active_job_queue_names; end
  def require_workers; end
  def validate_queues; end
  def validate_workers; end

  class << self
    def load_for_rails_console; end
    def setup_options(options); end
  end
end

class Shoryuken::Fetcher
  include ::Shoryuken::Util

  # @return [Fetcher] a new instance of Fetcher
  def initialize(group); end

  def fetch(queue, limit); end

  private

  def fetch_with_auto_retry(max_attempts); end
  def max_number_of_messages(limit, options); end
  def receive_messages(queue, limit); end
  def receive_options(queue); end
end

Shoryuken::Fetcher::FETCH_LIMIT = T.let(T.unsafe(nil), Integer)
module Shoryuken::HashExt; end

module Shoryuken::HashExt::DeepSymbolizeKeys
  def deep_symbolize_keys; end
end

module Shoryuken::HashExt::StringifyKeys
  def stringify_keys; end
end

module Shoryuken::HashExt::SymbolizeKeys
  def symbolize_keys; end
end

class Shoryuken::Launcher
  include ::Shoryuken::Util

  # @return [Launcher] a new instance of Launcher
  def initialize; end

  def start; end
  def stop; end
  def stop!; end

  private

  def create_managers; end
  def executor; end
  def initiate_stop; end
  def start_callback; end
  def start_managers; end
  def stop_callback; end
end

module Shoryuken::Logging
  class << self
    def initialize_logger(log_target = T.unsafe(nil)); end
    def logger; end
    def logger=(log); end
    def with_context(msg); end
  end
end

class Shoryuken::Logging::Pretty < ::Logger::Formatter
  # Provide a call() method that returns the formatted message.
  def call(severity, time, _program_name, message); end

  def context; end
end

class Shoryuken::Manager
  include ::Shoryuken::Util

  # @return [Manager] a new instance of Manager
  def initialize(fetcher, polling_strategy, concurrency, executor); end

  def start; end

  private

  def assign(queue_name, sqs_msg); end

  # @return [Boolean]
  def batched_queue?(queue); end

  def busy; end
  def dispatch; end
  def dispatch_batch(queue); end
  def dispatch_loop; end
  def dispatch_single_messages(queue); end
  def handle_dispatch_error(ex); end
  def patch_batch!(sqs_msgs); end
  def processor_done; end
  def ready; end

  # @return [Boolean]
  def running?; end
end

Shoryuken::Manager::BATCH_LIMIT = T.let(T.unsafe(nil), Integer)

# See https://github.com/phstc/shoryuken/issues/348#issuecomment-292847028
Shoryuken::Manager::MIN_DISPATCH_INTERVAL = T.let(T.unsafe(nil), Float)

class Shoryuken::Message
  # @return [Message] a new instance of Message
  def initialize(client, queue, data); end

  def attributes; end
  def body; end
  def change_visibility(options); end

  # Returns the value of attribute client.
  def client; end

  # Sets the attribute client
  #
  # @param value the value to set the attribute client to.
  def client=(_arg0); end

  # Returns the value of attribute data.
  def data; end

  # Sets the attribute data
  #
  # @param value the value to set the attribute data to.
  def data=(_arg0); end

  def delete; end
  def md5_of_body; end
  def md5_of_message_attributes; end
  def message_attributes; end
  def message_id; end

  # Returns the value of attribute queue_name.
  def queue_name; end

  # Sets the attribute queue_name
  #
  # @param value the value to set the attribute queue_name to.
  def queue_name=(_arg0); end

  # Returns the value of attribute queue_url.
  def queue_url; end

  # Sets the attribute queue_url
  #
  # @param value the value to set the attribute queue_url to.
  def queue_url=(_arg0); end

  def receipt_handle; end
  def visibility_timeout=(timeout); end
end

# Middleware is code configured to run before/after
# a message is processed.  It is patterned after Rack
# middleware. Middleware exists for the server
# side (when jobs are actually processed).
#
# To modify middleware for the server, just call
# with another block:
#
# Shoryuken.configure_server do |config|
#   config.server_middleware do |chain|
#     chain.add MyServerHook
#     chain.remove ActiveRecord
#   end
# end
#
# To insert immediately preceding another entry:
#
# Shoryuken.configure_server do |config|
#   config.server_middleware do |chain|
#     chain.insert_before ActiveRecord, MyServerHook
#   end
# end
#
# To insert immediately after another entry:
#
# Shoryuken.configure_server do |config|
#   config.server_middleware do |chain|
#     chain.insert_after ActiveRecord, MyServerHook
#   end
# end
#
# This is an example of a minimal server middleware:
#
# class MyServerHook
#   def call(worker_instance, queue, sqs_msg)
#     puts 'Before work'
#     yield
#     puts 'After work'
#   end
# end
module Shoryuken::Middleware; end

class Shoryuken::Middleware::Chain
  # @return [Chain] a new instance of Chain
  # @yield [_self]
  # @yieldparam _self [Shoryuken::Middleware::Chain] the object that the method was called on
  def initialize; end

  def add(klass, *args); end
  def clear; end
  def dup; end

  # Returns the value of attribute entries.
  def entries; end

  # @return [Boolean]
  def exists?(klass); end

  def insert_after(oldklass, newklass, *args); end
  def insert_before(oldklass, newklass, *args); end
  def invoke(*args, &final_action); end
  def prepend(klass, *args); end
  def remove(klass); end
  def retrieve; end
end

class Shoryuken::Middleware::Entry
  # @return [Entry] a new instance of Entry
  def initialize(klass, *args); end

  # Returns the value of attribute klass.
  def klass; end

  def make_new; end
end

module Shoryuken::Middleware::Server; end

class Shoryuken::Middleware::Server::AutoDelete
  def call(worker, queue, sqs_msg, _body); end
end

class Shoryuken::Middleware::Server::AutoExtendVisibility
  include ::Shoryuken::Util

  def call(worker, queue, sqs_msg, body); end

  private

  def auto_visibility_timer(worker, queue, sqs_msg, body); end
end

Shoryuken::Middleware::Server::AutoExtendVisibility::EXTEND_UPFRONT_SECONDS = T.let(T.unsafe(nil), Integer)

class Shoryuken::Middleware::Server::AutoExtendVisibility::MessageVisibilityExtender
  include ::Shoryuken::Util

  def auto_extend(_worker, queue, sqs_msg, _body); end
end

class Shoryuken::Middleware::Server::ExponentialBackoffRetry
  include ::Shoryuken::Util

  def call(worker, _queue, sqs_msg, _body); end

  private

  def get_interval(retry_intervals, attempts); end
  def handle_failure(sqs_msg, started_at, retry_intervals); end
  def next_visibility_timeout(interval, started_at); end
end

class Shoryuken::Middleware::Server::Timing
  include ::Shoryuken::Util

  def call(_worker, queue, _sqs_msg, _body); end
end

class Shoryuken::Options
  class << self
    # @return [Boolean]
    def active_job?; end

    def active_job_queue_name_prefixing; end
    def active_job_queue_name_prefixing=(active_job_queue_name_prefixing); end
    def add_group(group, concurrency = T.unsafe(nil), delay: T.unsafe(nil)); end
    def add_queue(queue, weight, group); end
    def cache_visibility_timeout=(cache_visibility_timeout); end

    # @return [Boolean]
    def cache_visibility_timeout?; end

    # @yield [@@client_chain]
    def client_middleware; end

    # @yield [_self]
    # @yieldparam _self [Shoryuken::Options] the object that the method was called on
    def configure_client; end

    # @yield [_self]
    # @yieldparam _self [Shoryuken::Options] the object that the method was called on
    def configure_server; end

    def default_worker_options; end
    def default_worker_options=(default_worker_options); end
    def delay(group); end
    def groups; end
    def launcher_executor; end
    def launcher_executor=(launcher_executor); end
    def logger; end

    # Register a block to run at a point in the Shoryuken lifecycle.
    # :startup, :quiet or :shutdown are valid events.
    #
    #   Shoryuken.configure_server do |config|
    #     config.on(:shutdown) do
    #       puts "Goodbye cruel world!"
    #     end
    #   end
    def on(event, &block); end

    def on_start(&block); end
    def on_stop(&block); end
    def options; end
    def polling_strategy(group); end
    def register_worker(*args); end

    # @return [Boolean]
    def server?; end

    # @yield [@@server_chain]
    def server_middleware; end

    def sqs_client; end
    def sqs_client=(sqs_client); end
    def sqs_client_receive_message_opts; end
    def sqs_client_receive_message_opts=(sqs_client_receive_message_opts); end
    def start_callback; end
    def start_callback=(start_callback); end
    def stop_callback; end
    def stop_callback=(stop_callback); end
    def ungrouped_queues; end
    def worker_executor; end
    def worker_executor=(worker_executor); end
    def worker_registry; end
    def worker_registry=(worker_registry); end

    private

    def default_client_middleware; end
    def default_server_middleware; end
  end
end

Shoryuken::Options::DEFAULTS = T.let(T.unsafe(nil), Hash)
module Shoryuken::Polling; end

class Shoryuken::Polling::BaseStrategy
  include ::Shoryuken::Util

  def ==(other); end
  def active_queues; end
  def delay; end
  def messages_found(_queue, _messages_found); end
  def next_queue; end
end

class Shoryuken::Polling::QueueConfiguration < ::Struct
  def ==(other); end
  def eql?(other); end
  def hash; end

  # Returns the value of attribute name
  #
  # @return [Object] the current value of name
  def name; end

  # Sets the attribute name
  #
  # @param value [Object] the value to set the attribute name to.
  # @return [Object] the newly set value
  def name=(_); end

  # Returns the value of attribute options
  #
  # @return [Object] the current value of options
  def options; end

  # Sets the attribute options
  #
  # @param value [Object] the value to set the attribute options to.
  # @return [Object] the newly set value
  def options=(_); end

  def to_s; end

  class << self
    def [](*_arg0); end
    def inspect; end
    def keyword_init?; end
    def members; end
    def new(*_arg0); end
  end
end

class Shoryuken::Polling::StrictPriority < ::Shoryuken::Polling::BaseStrategy
  # @return [StrictPriority] a new instance of StrictPriority
  def initialize(queues, delay = T.unsafe(nil)); end

  def active_queues; end
  def messages_found(queue, messages_found); end
  def next_queue; end

  private

  def next_active_queue; end
  def pause(queue); end

  # @return [Boolean]
  def queue_paused?(queue); end

  # @return [Boolean]
  def queues_unpaused_since?; end

  def reset_next_queue; end
end

class Shoryuken::Polling::WeightedRoundRobin < ::Shoryuken::Polling::BaseStrategy
  # @return [WeightedRoundRobin] a new instance of WeightedRoundRobin
  def initialize(queues, delay = T.unsafe(nil)); end

  def active_queues; end
  def messages_found(queue, messages_found); end
  def next_queue; end

  private

  def current_queue_weight(queue); end
  def maximum_queue_weight(queue); end
  def pause(queue); end
  def queue_weight(queues, queue); end
  def unpause_queues; end
end

class Shoryuken::Processor
  include ::Shoryuken::Util

  # @return [Processor] a new instance of Processor
  def initialize(queue, sqs_msg); end

  def process; end

  # Returns the value of attribute queue.
  def queue; end

  # Returns the value of attribute sqs_msg.
  def sqs_msg; end

  private

  def body; end
  def parse_body(sqs_msg); end
  def worker; end
  def worker_class; end

  class << self
    def process(queue, sqs_msg); end
  end
end

class Shoryuken::Queue
  include ::Shoryuken::Util

  # @return [Queue] a new instance of Queue
  def initialize(client, name_or_url); end

  # Returns the value of attribute client.
  def client; end

  # Sets the attribute client
  #
  # @param value the value to set the attribute client to.
  def client=(_arg0); end

  def delete_messages(options); end

  # @return [Boolean]
  def fifo?; end

  # Returns the value of attribute name.
  def name; end

  # Sets the attribute name
  #
  # @param value the value to set the attribute name to.
  def name=(_arg0); end

  def receive_messages(options); end
  def send_message(options); end
  def send_messages(options); end

  # Returns the value of attribute url.
  def url; end

  # Sets the attribute url
  #
  # @param value the value to set the attribute url to.
  def url=(_arg0); end

  def visibility_timeout; end

  private

  def add_fifo_attributes!(options); end
  def queue_attributes; end
  def sanitize_message!(options); end
  def sanitize_messages!(options); end
  def set_by_name(name); end
  def set_by_url(url); end
  def set_name_and_url(name_or_url); end
end

Shoryuken::Queue::FIFO_ATTR = T.let(T.unsafe(nil), String)
Shoryuken::Queue::MESSAGE_GROUP_ID = T.let(T.unsafe(nil), String)
Shoryuken::Queue::VISIBILITY_TIMEOUT_ATTR = T.let(T.unsafe(nil), String)
module Shoryuken::StringExt; end

module Shoryuken::StringExt::Constantize
  def constantize; end
end

module Shoryuken::Util
  def elapsed(started_at); end
  def fire_event(event, reverse = T.unsafe(nil), event_options = T.unsafe(nil)); end
  def logger; end
  def unparse_queues(queues); end
  def worker_name(worker_class, sqs_msg, body = T.unsafe(nil)); end
end

Shoryuken::VERSION = T.let(T.unsafe(nil), String)

module Shoryuken::Worker
  mixes_in_class_methods ::Shoryuken::Worker::ClassMethods

  class << self
    # @private
    def included(base); end
  end
end

module Shoryuken::Worker::ClassMethods
  # @return [Boolean]
  def auto_delete?; end

  # @return [Boolean]
  def auto_visibility_timeout?; end

  # @return [Boolean]
  def exponential_backoff?; end

  def get_shoryuken_options; end
  def perform_async(body, options = T.unsafe(nil)); end
  def perform_at(interval, body, options = T.unsafe(nil)); end
  def perform_in(interval, body, options = T.unsafe(nil)); end

  # @yield [@server_chain]
  def server_middleware; end

  def shoryuken_class_attribute(*attrs); end
  def shoryuken_options(opts = T.unsafe(nil)); end
  def stringify_keys(hash); end

  private

  def normalize_worker_queue!; end
  def register_worker(queue); end
end

class Shoryuken::Worker::DefaultExecutor
  class << self
    def perform_async(worker_class, body, options = T.unsafe(nil)); end
    def perform_in(worker_class, interval, body, options = T.unsafe(nil)); end
  end
end

class Shoryuken::Worker::InlineExecutor
  class << self
    def perform_async(worker_class, body, options = T.unsafe(nil)); end
    def perform_in(worker_class, _interval, body, options = T.unsafe(nil)); end

    private

    def call(worker_class, sqs_msg); end
  end
end

class Shoryuken::WorkerRegistry
  # @return [Boolean]
  def batch_receive_messages?(_queue); end

  def clear; end
  def fetch_worker(_queue, _message); end
  def queues; end
  def register_worker(_queue, _clazz); end
  def workers(_queue); end
end
