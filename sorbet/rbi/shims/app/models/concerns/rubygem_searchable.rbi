# typed: true

module RubygemSearchable
  module ClassMethods
    def legacy_search(query); end
  end

  mixes_in_class_methods ClassMethods
end
