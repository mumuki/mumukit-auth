module Mumukit::Auth
  module Roles
    ROLES = [:student, :teacher, :head, :writer, :editor, :janitor, :owner]

    ROLES.each do |role|
      define_method "#{role}?" do |scope|
        has_role? role.to_sym, scope
      end
    end
  end
end

