module LucidEdge
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

      def to=(node)
        @changed_to_cid = node.to_cid
        node
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
        def attributes
          attribute_options.keys
        end

        def attribute_options
          @attribute_options ||= { id: {} }
        end

        def edge_from_cid(cid)
          Isomorfeus.cached_edge_class(cid[0]).new({id: cid[1]})
        end
      end

      if RUBY_ENGINE == 'opal'
        def initialize(attributes_hash = nil)
          attributes_hash = {} unless attributes_hash
          self.class.attributes.each do |attr|
            next if attr == :to || attr == :from
            if attributes_hash.key?(attr)
              validate_attribute!(attr, attributes_hash[attr])
              changed_attributes[attr] = attributes_hash[attr]
            elsif self.class.attribute_options[attr].key?(:default)
              changed_attributes[attr] = self.class.attribute_options[attr][:default]
            end
          end
          @id = attributes_hash[:id].to_s
          @id = "new_#{object_id}" if @id.empty?
          @changed_from_cid = attributes_hash[:from]&.to_cid
          @changed_to_cid = attributes_hash[:to]&.to_cid
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          Redux.fetch_by_path(:data_state, :edges, @class_name, @id) ? true : false
        end

        def from
          cid = from_as_cid
          cid ? LucidNode::Base.node_from_cid(cid) : nil
        end

        def from_as_cid
          return @changed_from_cid if @changed_from_cid
          cid = Redux.fetch_by_path(:data_state, :edges, @class_name, @id, :from)
          cid ? cid : nil
        end

        def from=(node)
          @changed_from_cid = node.to_cid
          node
        end

        def to
          cid = to_as_cid
          cid ? LucidNode::Base.node_from_cid(cid) : nil
        end

        def to_as_cid
          return @changed_to_cid if @changed_to_cid
          cid = Redux.fetch_by_path(:data_state, :edges, @class_name, @id, :to)
          cid ? cid : nil
        end

        def to_transport(*args)
          final_attributes = {}
          self.class.attributes.each do |attr|
            next if attr == :id
            final_attributes[attr] = send(attr)
          end
          { 'edges' => { @class_name => { @id => { from: from_as_cid, to: to_as_cid, attributes: final_attributes }}}}
        end

        base.instance_exec do
          def attribute(name, options = {})
            attribute_options[name] = options

            define_method(name) do
              if changed_attributes.key?(name)
                changed_attributes[name]
              else
                Redux.fetch_by_path(:data_state, :edges, @class_name, @id, :attributes, name)
              end
            end

            define_method("#{name}=") do |arg|
              validate_attribute!(name, arg)
              changed_attributes.set(name, arg)
            end
          end
        end
      else # RUBY_ENGINE
        def initialize(attributes_hash = nil)
          attributes_hash = {} unless attributes_hash
          given_attributes = Isomorfeus::Data::Props.new(attributes_hash)
          valid_attributes_hash = {}
          self.class.attributes.each do |attr|
            next if attr == :to || attr == :from
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
          @from_cid = given_attributes[:from]&.to_cid
          @changed_from_cid = nil
          @to_cid = given_attributes[:to]&.to_cid
          @changed_to_cid = nil
          @class_name = self.class.name
          @class_name = @class_name.split('>::').last if @class_name.start_with?('#<')
        end

        def loaded?
          true
        end

        def from
          from_cid = from_as_cid
          from_cid ? LucidNode::Base.node_from_cid(from_cid) : nil
        end

        def from_as_cid
          @changed_from_cid ? @changed_from_cid : @from_cid
        end

        def from=(node)
          @changed_from_cid = node.to_cid
          node
        end

        def to
          to_cid = to_as_cid
          to_cid ? LucidNode::Base.node_from_cid(to_cid) : nil
        end

        def to_as_cid
          @changed_to_cid ? @changed_to_cid : @to_cid
        end

        def to_transport(*args)
          final_attributes = {}
          self.class.attributes.each do |attr|
            next if attr == :id
            include_attribute = @attributes.key?(attr)
            include_attribute = !self.class.attribute_options[attr][:server_only] if self.class.attribute_options[attr].key?(:server_only)
            final_attributes[attr.to_s] = @attributes[attr] if include_attribute
          end
          { 'edges' => { @class_name => { @id => { 'from' => from_as_cid, 'to' => to_as_cid, 'attributes' => final_attributes }}}}
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
