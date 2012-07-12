class LockVersionHelper

  @@lock_version = nil

  def self.lock_version= (new_version)
	 @@lock_version = new_version
  end

  def self.lock_version
    @@lock_version
  end
end