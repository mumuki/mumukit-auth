module Mumukit::Auth
  module Roles
    FINE_GRAINED_ROLES = [
      :ex_student, :student, :teacher, :headmaster, :writer, :editor, :janitor,
      :moderator, :manager
    ]
    COARSE_GRAINED_ROLES = [:supervisor, :admin, :owner]

    ROLES = COARSE_GRAINED_ROLES + FINE_GRAINED_ROLES


    ROLES.each do |role|
      define_method "#{role}?" do |scope = Mumukit::Auth::Slug.any|
        has_permission? role.to_sym, scope
      end
    end
  end
end
