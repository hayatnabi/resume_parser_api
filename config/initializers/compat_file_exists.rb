class File
  def self.exists?(path)
    self.exist?(path)
  end
end
# This initializer ensures compatibility with older code that uses `File.exists?`
