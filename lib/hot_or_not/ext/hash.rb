class Hash
  def <=> other
    self.sort.to_s <=> other.sort.to_s
  end
end
