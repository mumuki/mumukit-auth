module Mumukit::Auth
  class Store

    def initialize(db_name)
      @db = Daybreak::DB.new "#{db_name}.db", default: {}
    end

    def set!(key, value)
      @db.lock do
        @db.update! :"#{key}" => value.to_json
      end
    end

    def get(key)
      Mumukit::Auth::Permissions.load @db[key]
    end

    def close
      @db.close
    end
  end
end