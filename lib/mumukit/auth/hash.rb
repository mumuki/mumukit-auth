class Hash
  def dig(key, *keys)
    value = self[key]
    if !value.nil? && !keys.empty?
      value.dig(*keys)
    else
      value
    end
  end
end