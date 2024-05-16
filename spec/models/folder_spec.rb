# == Schema Information
#
# Table name: folders
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_folders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Folder, type: :model do
  describe "validations" do
    context "with valid attributes" do
      let(:folder) { build(:folder, :with_user) }

      it "is valid" do
        expect(folder).to be_valid
      end

      context "when a user is creating a folder with the same name than an other user" do
        let!(:folder1) { create(:folder, :with_user, name: "rock") }
        let!(:folder2) { create(:folder, :with_user, name: "rock") }

        it "it is valid" do
          expect(Folder.where(name: "rock").count).to eq(2)
        end
      end
    end

    context "with invalid attributes" do
      context "when no name is provided" do
        it "it is not valid" do
          expect(build(:folder, :with_user, name: nil)).not_to be_valid
        end
      end

      context "when user already has a folder with the same name" do
        let(:user) { create(:user) }

        it "it is not valid" do
          create(:folder, name: "rock", user: user)
          expect(build(:folder, name: "rock", user: user)).not_to be_valid
        end
      end
    end
  end
end
