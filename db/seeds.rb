# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


category_list = [
  "Contact Lens",
  "Baby Products",
  "Supplements",
  "Personal Grooming",
  "Food Related",
  "Home Related",
  "Pet Related",
  "Others"
]

category_list.each do |name|
  Category.create(name: name)
end

bountytype_list = [
  "Bounty Only",
  "Bounty with Deposit",
  "Full Sum",
]

bountytype_list.each do |name|
  Bountytype.create(name: name)
end
