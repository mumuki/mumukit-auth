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

  def librarian?(slug)
    allows? 'bibliotheca', slug
  end

  def admin?(slug)
    allows? 'admin', slug
  end

  def teacher?(slug)
    allows? 'classroom', slug
  end

  def student?(slug)
    allows? 'atheneum', slug
  end

  def self.load(json)
    new(JSON.parse(json))
  end

  def self.dump(metadata)
    metadata.to_json
  end

  private

  def allows?(app, slug)
    permissions(app).allows? slug
  end
end
