# api
# class:
#   attribute :my_attribute, server_only: false|true, class: ClassName, is_a: ClassName, default: value, validate: block
#   my_node.class.attributes
#   my_node.class.attribute_options
# instance:
#   my_node.my_attribute
#   my_node.my_attribute = value
#   my_node.changed_attributes
#   my_node.changed?
#   my_node.loaded?
#   my_node.valid_attribute?(attr, value)
#   my_node.validate_attribute!(attr, value)
#   my_node.to_transport

module LucidNode
  module Mixin
    def self.included(base)
      attr_reader :id

      def ==(other_node)
        eql?(other_node)
      end

      def eql?(other_node)
        @id == other_node.id && @class_name == other_node.instance_variable_get(:@class_name)
      end

      def id=(new_id)
        new_id = new_id.to_s
        changed_attributes[:id] = new_id
        @id = new_id
      end

      def changed_attributes
        @changed_attributes ||= Isomorfeus::Data::Props.new({})
      end

      def changed?
        changed_attributes.any?
      end

      def to_cid
        [@class_name, @id]
      end

      def valid_attribute?(attr, value)
        begin
          validate_attribute!(attr, value)
          true
        rescue
          false
        end
      end

      def validate_attribute!(attr, value)
        attr_options = self.class.attribute_options[attr]

        if attr_options.key?(:class)
          raise "#{attr}: value class is not #{attr_options[:class]}!" unless value.class == attr_options[:class]
        end

        if attr_options.key?(:is_a)
          raise "#{attr}: value is not a #{attr_options[:class]}!" unless value.is_a?(attr_options[:is_a])
        end

        if attr_options.key?(:validate)
          raise "#{attr}: value failed validation!" unless attr_options[:validate].call(value)
        end
      end

      base.instance_exec do
        def query_block
          @query_block
        end

        def attributes
          attribute_options.keys
        end

        def attribute_options
          @attribute_options ||= { id: {} }
        end

        def node_from_cid(cid)
          Isomorfeus.cached_node_class(cid[0]).new({id: cid[1]})
        end
      end

      if RUBY_ENGINE == 'opal'
        def initialize(attributes_hash = nil)
          attributes_hash = {} unless attributes_hash
          self.class.attributes.each do |attr|
            if attributes_hash.key?(attr)
              validate_attribute!(attr, attributes_hash[attr])
              changed_attributes[attr] = attributes_hash[attr]
            elsif self.class.attribute_options[attr].key?(:default)
              changed_attributes[attr] = self.class.attribute_options[attr][:default]
            end
          end
          @id = attributes_hash[:id].to_s
          @id = "new_#{object_id}" if @id.empty?
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          Redux.fetch_by_path(:data_state, :node, @class_name, :instances, @id) ? true : false
        end

        def to_transport(*args)
          final_attributes = {}
          self.class.attributes.each do |attr|
            next if attr == :id
            final_attributes[attr] = send(attr)
          end
          { 'nodes' => { @class_name => { @id => { attributes: final_attributes }}}}
        end

        base.instance_exec do
          def attribute(name, options = {})
            attribute_options[name] = options

            define_method(name) do
              if changed_attributes.key?(name)
                changed_attributes[name]
              else
                Redux.fetch_by_path(:data_state, :nodes, @class_name, @id, :attributes, name)
              end
            end

            define_method("#{name}=") do |arg|
              validate_attribute!(name, arg)
              changed_attributes.set(name, arg)
            end
          end

          def query
            nil
          end
        end
      else # RUBY_ENGINE
        def initialize(attributes_hash = nil)
          attributes_hash = {} unless attributes_hash
          given_attributes = Isomorfeus::Data::Props.new(attributes_hash)
          valid_attributes_hash = {}
          self.class.attributes.each do |attr|
            if given_attributes.key?(attr)
              validate_attribute!(attr, given_attributes[attr])
              valid_attributes_hash[attr] = given_attributes[attr]
            elsif self.class.attribute_options[attr].key?(:default)
              valid_attributes_hash[attr] = self.class.attribute_options[attr][:default]
            end
          end
          @attributes = Isomorfeus::Data::Props.new(valid_attributes_hash)
          @id = @attributes[:id].to_s
          @id = "new_#{object_id}" if @id.empty?
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          true
        end

        def to_transport(*args)
          final_attributes = {}
          self.class.attributes.each do |attr|
            next if attr == :id
            include_attribute = @attributes.key?(attr)
            include_attribute = !self.class.attribute_options[attr][:server_only] if self.class.attribute_options[attr].key?(:server_only)
            final_attributes[attr.to_s] = send(attr) if include_attribute
          end
          { 'nodes' => { @class_name => { @id => { 'attributes' => final_attributes }}}}
        end

        base.instance_exec do
          def attribute(name, options = {})
            attribute_options[name] = options

            define_method(name) do
              if changed_attributes.key?(name)
                changed_attributes[name]
              else
                @attributes[name]
              end
            end

            define_method("#{name}=") do |arg|
              validate_attribute!(name, arg)
              changed_attributes.set(name, arg)
            end
          end
        end
      end # RUBY_ENGINE
    end
  end
end
