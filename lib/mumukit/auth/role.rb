module Mumukit::Auth
  class Role
    def initialize(symbol)
      @symbol=symbol
    end

    def allows?(resource_slug, permissions)
      permissions.role_allows?(to_sym, resource_slug) ||
          parent_allows?(resource_slug, permissions)
    end

    def parent_allows?(resource_slug, permissions)
      parent.allows?(resource_slug, permissions)
    end

    def to_sym
      @symbol
    end

    def broader_than?(other)
      other.narrower_than? self
    end

    def narrower_than?(other)
      other.class != self.class && narrower_than_other?(other)
    end

    private

    def narrower_than_other?(other)
      self.parent.class == other.class || self.parent.narrower_than?(other)
    end

    class << self
      def parent(parent)
        define_method(:parent) { self.class.parse(parent) }
      end

      def parse(role)
        @roles ||= {}
        @roles[role] ||= "Mumukit::Auth::Role::#{role.to_s.camelize}".constantize.new(role.to_sym)
      end

      alias [] parse
    end


    class ExStudent < Role
      parent :student
    end
    class Student < Role
      parent :teacher
    end
    class Teacher < Role
      parent :headmaster
    end
    class Headmaster < Role
      parent :janitor
    end
    class Writer < Role
      parent :editor
    end
    class Editor < Role
      parent :admin
    end
    class Janitor < Role
      parent :admin
    end
    class Moderator < Role
      parent :forum_supervisor
    end
    class ForumSupervisor < Role
      parent :admin
    end
    class Admin < Role
      parent :owner
    end
    class Owner < Role
      parent nil

      def parent_allows?(*)
        false
      end

      def narrower_than_other?(*)
        false
      end
    end
  end
end
