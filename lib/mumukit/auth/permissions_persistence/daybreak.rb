module Mumukit::Auth
  module PermissionsPersistence
    class Daybreak
      def self.from_config
        new Mumukit::Auth.config.daybreak_name
      end

      def initialize(db_name)
        @db = ::Daybreak::DB.new "#{db_name}.db", default: '{}'
      end

      def close
        @db.close
      end

      def set!(key, value)
        @db.update! key.to_sym => value.to_json
      end

      def get(key)
        Mumukit::Auth::Permissions.load @db[key]
      end

      def clean_env!
        FileUtils.rm ["#{Mumukit::Auth.config.daybreak_name}.db"], force: true
      end
    end
  end
end
