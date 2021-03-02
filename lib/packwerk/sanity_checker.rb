# typed: false
# frozen_string_literal: true

require "packwerk/application_validator"

module Packwerk
  # To do: This alias and file should be removed as it is deprecated
  warn("DEPRECATION WARNING: Packwerk::SanityChecker is deprecated, use Packwerk::ApplicationValidator instead.")
  SanityChecker = ApplicationValidator
end
