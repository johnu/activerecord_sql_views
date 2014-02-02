module ActiveRecordSqlViews
  module ActiveRecord
    module ConnectionAdapters

      module AbstractAdapter
        def self.included(base) #:nodoc:
          base.alias_method_chain :initialize, :ar_sql_views
        end

        def initialize_with_ar_sql_views(*args) #:nodoc:
          initialize_without_ar_sql_views(*args)
          adapter = case adapter_name
                    when 'PostgreSQL', 'PostGIS'   then 'PostgresqlAdapter'
                    when 'SQLite'                  then 'Sqlite3Adapter'
                    end
          unless adapter
            ::ActiveRecord::Base.logger.warn "ActiveRecordSqlViews: Unsupported adapter name #{adapter_name.inspect}.  Leaving it alone."
            return
          end
          adapter_module = ActiveRecordSqlViews::ActiveRecord::ConnectionAdapters.const_get(adapter)
          self.class.send(:include, adapter_module) unless self.class.include?(adapter_module)

        end

        def create_view(view_name, definition, options={})
          definition = definition.to_sql if definition.respond_to? :to_sql
          execute "DROP VIEW IF EXISTS #{quote_table_name(view_name)}" if options[:force]
          execute "CREATE VIEW #{quote_table_name(view_name)} AS #{definition}"
        end

        def drop_view(view_name)
          execute "DROP VIEW #{quote_table_name(view_name)}"
        end
      end
    end
  end
end
