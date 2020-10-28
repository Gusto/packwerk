# typed: strict
# frozen_string_literal: true

module Packwerk
  # Exracts the constant reference from a fixture call
  class ConstantFixtureInspector
    class Fixture < T::Struct
      extend T::Sig

      const :content, T::Hash[String, T.untyped]
      const :path, String

      class << self
        extend T::Sig

        sig { params(base: String, path: String).returns(Fixture) }
        def load(base, path)
          fixture_path = File.join(base, path)
          content = YAML.load_file(fixture_path)
          new(content: content, path: path)
        end
      end

      sig { returns(String) }
      def model_class
        model_class = content.dig("_fixture", "model_class")
        if model_class.present?
          model_class
        else
          path_without_extension.classify
        end
      end

      private

      sig { returns(String) }
      def path_without_extension
        T.must(path[0...-4])
      end
    end
  end
end
