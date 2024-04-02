# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Reset all the database
User.destroy_all
FollowedArtist.destroy_all
Artist.destroy_all

# Create a default user
begin
  User.create!(username: "john_doe", email: "john.doe@gmail.com", password: "azerty")
rescue ActiveRecord::RecordInvalid => e
  Rails.logger.error("Error while creating the user : #{e.message}")
else
  puts "Created #{User.count} user"
end



