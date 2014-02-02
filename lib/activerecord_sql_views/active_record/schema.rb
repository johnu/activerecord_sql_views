module ActiveRecordSqlViews
  module ActiveRecord
    module Schema #:nodoc: all
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def self.extended(base)
          class << base
            alias_method_chain :define, :activerecord_sql_views
          end
        end

        def define_with_activerecord_sql_views(info={}, &block)
          fk_override = { :auto_create => false, :auto_index => false }
          save = Hash[fk_override.keys.collect{|key| [key, ActiveRecordSqlViews.config.foreign_keys.send(key)]}]
          begin
            ActiveRecordSqlViews.config.foreign_keys.update_attributes(fk_override)
            define_without_activerecord_sql_views(info, &block)
          ensure
            ActiveRecordSqlViews.config.foreign_keys.update_attributes(save)
          end
        end
      end
    end
  end
end
