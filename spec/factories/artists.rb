# == Schema Information
#
# Table name: artists
#
#  id            :uuid             not null, primary key
#  external_link :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :artist do
    name { "MyString" }
    external_link { "MyString" }
    avatar { nil }
  end
end
