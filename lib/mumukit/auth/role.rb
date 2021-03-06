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

    private

    def self.parent(parent)
      define_method(:parent) { self.class.parse(parent) }
    end

    def self.parse(role)
      @roles ||= {}
      @roles[role] ||= "Mumukit::Auth::Role::#{role.to_s.camelize}".constantize.new(role.to_sym)
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
    end
  end
end
