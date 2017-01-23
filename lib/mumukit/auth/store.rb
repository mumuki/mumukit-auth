module Mumukit::Auth
  module Store
    def self.clean!
      persistence_strategy.clean!
    end

    def self.set!(*args)
      persistence_strategy.set!(*args)
    end

    def self.get(key)
      persistence_strategy.get(key)
    end

    def self.persistence_strategy
      Mumukit::Auth.config.persistence_strategy
    end
  end
end