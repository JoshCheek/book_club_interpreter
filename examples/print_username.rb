class User
  def initialize(name)
    self.name = name
  end

  def name
    @name
  end

  def name=(name)
    @name = name
  end

  def location
    "the book club!"
  end

  def friends
    "Austin and Lovisa!"
  end
end

user = User.new("Josh")
puts user.name
puts "was at"
puts user.location
puts "with"
puts user.friends
