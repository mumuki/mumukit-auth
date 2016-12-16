module Mumukit::Auth
  class Store

    def initialize(db_name)
      @db = Daybreak::DB.new "#{db_name}.db", default: '{}'
    end

    def set!(key, value)
      @db.update! key.to_sym => value.to_json
    end

    def get(key)
      Mumukit::Auth::Permissions.load @db[key]
    end

    def close
      @db.close
    end
  end
end