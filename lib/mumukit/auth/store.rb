module Mumukit::Auth
  class Store
    def initialize(db_name)
      @db = Daybreak::DB.new "#{db_name}.db", default: '{}'
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

    class << self
      def from_env
        new Mumukit::Auth.config.daybreak_name
      end

      def with(&block)
        store = from_env
        block.call store
      ensure
        store.close
      end

      def set!(*args)
        with { |store| store.set!(*args) }
      end

      def get(key)
        with { |store| store.get(key) }
      end
    end
  end
end