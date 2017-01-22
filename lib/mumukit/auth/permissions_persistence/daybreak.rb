module Mumukit::Auth
  module PermissionsPersistence
    class Daybreak
      def initialize(db_name = 'permissions')
        @db_name = db_name
        at_exit { @db.close if @db }
      end

      def set!(key, value)
        db.update! key.to_sym => value.to_json
        db.flush
      end

      def get(key)
        Mumukit::Auth::Permissions.load db[key]
      end

      def clean!
        db.clear
      end

      private

      def db
        @db ||= ::Daybreak::DB.new "#{@db_name}.db", default: '{}'
      end
    end
  end
end
