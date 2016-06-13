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
      @json[app] = process_permission(app, permission)
    else
      @json.merge!("#{app}" => {'permissions' => permission})
    end
    @json
  end

  def process_permission(app, permission)
    {permissions: Mumukit::Auth::Permissions.load(permissions(app).as_json + ":#{permission}").to_s}
  end

  def librarian?(slug)
    has_role? 'bibliotheca', slug
  end

  def admin?(slug)
    has_role? 'admin', slug
  end

  def teacher?(slug)
    has_role? 'classroom', slug
  end

  def student?(slug)
    has_role? 'atheneum', slug
  end

  def self.load(json)
    new(JSON.parse(json))
  end

  def self.dump(metadata)
    metadata.to_json
  end

  private

  def has_role?(app, slug)
    permissions(app)[slug]
  end
end
