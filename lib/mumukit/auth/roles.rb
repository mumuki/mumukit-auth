module Mumukit::Auth
  module Roles
    ROLES = [:student, :teacher, :headmaster, :writer, :editor, :janitor, :moderator, :owner]

    ROLES.each do |role|
      define_method "#{role}?" do |scope = Mumukit::Auth::Slug.any|
        allows? role.to_sym, scope
      end
    end
  end
end

