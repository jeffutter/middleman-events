module Middleman
  module Events

    class FancyHash

      def has_prop?(prop)
        if i_get.include?(prop.to_s)
          true
        else
          false
        end
      end

      def method_missing(method_sym, *arguments, &block)
        if i_get.include? method_sym.to_s
          i_get[method_sym.to_s]
        else
          super
        end
      end

      def respond_to?(method_sym, include_private = false)
        if i_get.include? method_sym.to_s
          true
        else
          super
        end
      end

      def i_get
        instance_variable_get("@#{self.class.to_s.split('::').last.downcase}")
      end

    end

  end
end