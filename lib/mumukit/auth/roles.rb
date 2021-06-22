module Mumukit::Auth
  module Roles
    ROLES = [:ex_student, :student, :teacher, :headmaster, :writer, :editor, :janitor, :moderator, :forum_supervisor, :admin, :owner]

    ROLES.each do |role|
      define_method "#{role}?" do |scope = Mumukit::Auth::Slug.any|
        has_permission? role.to_sym, scope
      end
    end
  end
end

