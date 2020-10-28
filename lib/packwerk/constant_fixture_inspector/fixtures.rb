# typed: strict
# frozen_string_literal: true

require "packwerk/constant_fixture_inspector/fixture"

module Packwerk
  # Exracts the constant reference from a fixture call
  class ConstantFixtureInspector
    class Fixtures
      extend T::Sig

      sig { params(base: String).void }
      def initialize(base)
        @base = T.let(base, String)
      end

      sig { params(method_name: String).returns(T.nilable(Fixture)) }
      def find_by!(method_name:)
        relative_fixture_path = fixtures_by_method_names[method_name]
        return unless relative_fixture_path

        load_fixture(relative_fixture_path)
      end

      private

      sig { returns(String) }
      attr_reader :base

      sig { returns(T::Hash[String, String]) }
      def fixtures_by_method_names
        @fixtures_by_method_names = T.let(@fixtures_by_method_names, T.nilable(T::Hash[String, String]))

        @fixtures_by_method_names ||= retrieve_fixture_files_for_methods
      end

      sig { returns(T::Hash[String, String]) }
      def retrieve_fixture_files_for_methods
        fixture_files.each_with_object({}) do |file_path, hash|
          key = method_name_from_path(file_path)
          hash[key] = file_path
        end
      end

      sig { params(path: String).returns(String) }
      def method_name_from_path(path)
        path_without_extension = path[0...-4]
        T.must(path_without_extension).gsub("/", "_")
      end

      sig { returns(T::Array[String]) }
      def fixture_files
        Dir.glob("**/*.yml", base: base)
      end

      sig { params(path: String).returns(Fixture) }
      def load_fixture(path)
        @fixtures = T.let(@fixtures, T.nilable(T::Hash[String, Fixture]))

        @fixtures ||= {}
        @fixtures[path] ||= Fixture.load(base, path)
      end
    end
  end
end
