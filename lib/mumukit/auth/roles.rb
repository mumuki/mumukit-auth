module Mumukit::Auth
  module Roles
    ROLES = [:student, :teacher, :headmaster, :writer, :editor, :janitor, :owner]

    ROLES.each do |role|
      define_method "#{role}?" do |scope|
        has_permission? role.to_sym, scope
      end
    end
  end
end

