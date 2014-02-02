module ActiveRecordSqlViews
  module ActiveRecord
    module SchemaDumper

      def self.included(base) #:nodoc:
        base.class_eval do
          private
          alias_method_chain :tables, :ar_sql_views
        end
      end

      private

      def tables_with_ar_sql_views(stream) #:nodoc:
        tables_without_ar_sql_views(stream)

        @connection.views.each do |view_name|
          definition = @connection.view_definition(view_name)
          stream.puts "  create_view #{view_name.inspect}, #{definition.inspect}, :force => true\n\n"
        end
      end
    end
  end
end
