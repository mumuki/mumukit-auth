module Mumukit::Auth
  class Role
    def initialize(symbol)
      @symbol=symbol
    end

    # Tells wether the given authorizable object
    # can be authorized using the given permissions
    # by this role or its parent role
    #
    # This definition is recursive, thus traversing the whole ancenstry chain
    def allows?(authorizable, permissions)
      permissions.role_allows?(to_sym, authorizable) ||
          parent_allows?(authorizable, permissions)
    end

    def parent_allows?(authorizable, permissions)
      parent.allows?(authorizable, permissions)
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
      parent :owner
    end
    class Janitor < Role
      parent :owner
    end
    class Moderator < Role
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
