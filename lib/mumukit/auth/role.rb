
class String
  def to_mumukit_role
    Mumukit::Auth::Role.parse self
  end
end

class Symbol
  def to_mumukit_role
    Mumukit::Auth::Role.parse self
  end
end

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
      other.class != self.class && _narrower_than_other?(other)
    end

    def to_mumukit_role
      self
    end

    def _narrower_than_other?(other)
      self.parent.class == other.class || self.parent._narrower_than_other?(other)
    end

    class << self
      def parent(parent)
        define_method(:parent) { self.class.parse(parent) }
      end

      def parse(role)
        @roles ||= {}
        @roles[role.to_sym] ||= "Mumukit::Auth::Role::#{role.to_s.camelize}".constantize.new(role.to_sym)
      end
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
      parent :manager
    end
    class Janitor < Role
      parent :manager
    end
    class Moderator < Role
      parent :forum_supervisor
    end
    class ForumSupervisor < Role
      parent :manager
    end
    class Manager < Role
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

      def _narrower_than_other?(*)
        false
      end
    end
  end
end
