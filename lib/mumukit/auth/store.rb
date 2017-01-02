module Mumukit::Auth
  class Store
    def initialize
      @db = Mumukit::Auth.config.persistence_strategy
    end

    def set!(key, value)
      @db.set! key.to_sym, value
    end

    def get(key)
      @db.get key
    end

    def clean_env!
      @db.clean_env!
    end

    class << self

      def from_config
        Mumukit::Auth.config.persistence_strategy.class.from_config
      end

      def clean_env!
        from_config.clean_env!
      end

      def with(&block)
        store = from_config
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