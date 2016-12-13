class Mumukit::Auth::Metadata
  def initialize(json)
    @json = json
  end

  def as_json(_options={})
    @json
  end

  def permissions(app)
    @json.dig(app, 'permissions').to_mumukit_auth_permissions
  end

  def add_permission!(app, permission)
    if permissions(app).present?
      @json[app] = process_add_permission(app, permission)
    else
      @json.merge!("#{app}" => {'permissions' => permission})
    end
  end

  def remove_permission!(app, permission)
    if permissions(app).present?
      @json[app] = process_remove_permission(app, permission)
    end
    @json.delete(app) if @json.dig(app, 'permissions').blank?
  end

  def process_permission(new_permissions)
    {'permissions' => Mumukit::Auth::Permissions.load(new_permissions).to_s}
  end

  def process_remove_permission(app, permission)
    process_permission(permissions(app).as_json.split(':').reject { |it| it == permission }.join(':'))
  end

  def process_add_permission(app, permission)
    process_permission(permissions(app).as_json + ":#{permission}")
  end

  def librarian?(resource_slug)
    has_role? 'bibliotheca', resource_slug
  end

  def admin?(resource_slug)
    has_role? 'admin', resource_slug
  end

  def teacher?(resource_slug)
    has_role? 'classroom', resource_slug
  end

  def student?(resource_slug)
    has_role? 'atheneum', resource_slug
  end

  def self.load(json)
    new(JSON.parse(json))
  end

  def self.dump(metadata)
    metadata.to_json
  end

  private

  def has_role?(app, resource_slug)
    permissions(app).allows? resource_slug
  end
end
