module ActiveRecordSqlViews
  module ActiveRecord

    #
    # ActiveRecordSqlViews adds several methods to ActiveRecord::Base
    #
    module Base
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods #:nodoc:
        def self.extended(base) #:nodoc:
          class << base
          end
        end

      end
    end
  end
end
