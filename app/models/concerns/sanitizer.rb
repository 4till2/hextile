module Sanitizer
  extend ActiveSupport::Concern

  class_methods do
    def sanitize_params(arg)
      arg&.slice(*attribute_names.map(&:to_sym))
    end
  end

end