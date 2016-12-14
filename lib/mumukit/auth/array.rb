class Array
  # Expands the array to length, filling the blanks with the element given
  def pad_with(element, length)
    self.fill(element, self.length, length - self.length)
  end
end