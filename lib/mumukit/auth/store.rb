module Mumukit::Auth
  class Store

    def self.from_env
      new ENV['MUMUKI_DAYBREAK_NAME']
    end

    def initialize(db_name)
      @db = Daybreak::DB.new "#{db_name}.db", default: '{}'
    end

    def method_missing(name, *args, &block)
      if name.to_s.starts_with? 'safe_'
        action = name.to_s.split('safe_').last
        self.try do |db|
          value = db.send action, *args
          db.close
          return value
        end
      else
        super
      end
    end

    def close
      @db.close
    end

    private

    def set!(key, value)
      @db.update! key.to_sym => value.to_json
    end

    def get(key)
      Mumukit::Auth::Permissions.load @db[key]
    end
  end
end