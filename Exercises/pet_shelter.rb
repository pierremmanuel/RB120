class Pet
  attr_reader :animal, :name

  @@all_pets = []

  def self.all_pets
    @@all_pets
  end

  def initialize(animal, name)
    @animal = animal
    @name = name
    @@all_pets << self
  end

  def to_s
    "a #{animal} named #{name}"
  end

end

class Owner
  attr_reader :name, :pets

  def initialize(name)
    @name = name
    @pets = []
  end

  def add_pet(pet)
    @pets << pet
  end

  def number_of_pets
    pets.size
  end

  def print_pets
    puts pets
  end
end

class Shelter
  attr_reader :adopted_pets, :unadopted_pets

  def initialize
    @owners = {}
    @adopted_pets = []
    @unadopted_pets = Pet.all_pets
  end

  def adopt(owner, pet)
    owner.add_pet(pet)
    @owners[owner.name] ||= owner
    @adopted_pets << pet
    @unadopted_pets -= self.adopted_pets
  end

  def print_adoptions
    @owners.each_pair do |name, owner|
      puts "#{name} has adopted the following pets:"
      owner.print_pets
      puts
    end

    puts "The Animal Shelter has the following unadopted pets:"
    puts unadopted_pets
    puts
  end

end

butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
# shelter.adopt(bholmes, molly)
# shelter.adopt(bholmes, chester)
shelter.print_adoptions
puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."
puts
shelter.print_unadopted
puts "The Animal Shelter has #{shelter.unadopted_pets.size} unadopted pets."
