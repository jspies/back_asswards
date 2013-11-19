module BackAsswards
  class VersionCheck
    attr_accessor :scope, :version, :limit

    def initialize(version_object)
      self.limit = BackAsswards.config[:num_versions_to_allow]
      if version_object.is_a?(Array)
        self.scope = version_object.first
        self.version = version_object.last
      else
        self.version = version_object
      end
    end

    def old?
      case BackAsswards.config[:data_storage]
      when "ActiveRecord"
        relation = constantize(BackAsswards.config[:data]).order("#{BackAsswards.config[:version_field]} DESC")
        relation = relation.where(BackAsswards.config[:scope_field] => self.scope) if BackAsswards.config[:scope_field]
        !relation.limit(limit).all.include?(version)
      when "Array"
        !BackAsswards.config[:data].sort.reverse[0..limit - 1].include?(version)
      when "Hash"
        data = BackAsswards.config[:data][scope]
        !data.sort.reverse[0..limit - 1].include?(version)
      end
    end

    # stolen from ActiveSupport
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check it it's owned
          # directly before we reach Object or the end of ancestors.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end
  end
end