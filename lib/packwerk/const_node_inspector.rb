# typed: true
# frozen_string_literal: true

require "packwerk/constant_name_inspector"

module Packwerk
  # Extracts a constant name from an AST node of type :const
  class ConstNodeInspector
    include ConstantNameInspector

    def constant_name_from_node(node, ancestors:)
      return nil unless Node.constant?(node)
      # Only process the root `const` node for namespaced constant references. For example, in the
      # reference `Spam::Eggs::Thing`, we only process the const node associated with `Spam`.
      return nil if root_constant?(ancestors)

      if constant_in_module_or_class_definition?(node, ancestors: ancestors)
        fully_qualify_constant(node, ancestors: ancestors)
      else
        Node.constant_name(node)
      end
    rescue Node::TypeError
      nil
    end

    private

    def root_constant?(ancestors)
      parent = ancestors.first
      parent && Node.constant?(parent)
    end

    def constant_in_module_or_class_definition?(node, ancestors:)
      if (parent = ancestors.first)
        parent_name = Node.module_name_from_definition(parent)
        parent_name && parent_name == Node.constant_name(node)
      end
    end

    def fully_qualify_constant(node, ancestors:)
      # We're defining a class with this name, in which case the constant is implicitly fully qualified by its
      # enclosing namespace
      name = Node.parent_module_name(ancestors: ancestors)
      name ||= generate_qualified_constant(node, ancestors)
      "::" + name
    end

    def generate_qualified_constant(node, ancestors:)
      namespace_path = Node.enclosing_namespace_path(node, ancestors: ancestors)
      constant_name = Node.constant_name(node)
      namespace_path.push(constant_name).join("::")
    end
  end
end
