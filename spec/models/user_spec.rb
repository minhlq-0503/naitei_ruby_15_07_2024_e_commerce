require "rails_helper"

RSpec.describe User, type: :model do
  describe "attribute validations" do
    describe "presence of" do
      subject{create :user}
      it {is_expected.to validate_presence_of(:user_name)}
      it {is_expected.to validate_presence_of(:email)}
      it {is_expected.to validate_presence_of(:password)}
      it {is_expected.to validate_presence_of(:phone)}
    end
  end

  describe "associations" do
    describe 'associations' do
      # Testing has_many associations
      it { should have_many(:addresses).dependent(:destroy) }
      it { should have_many(:carts).dependent(:destroy) }
      it { should have_many(:orders).dependent(:nullify) }
      it { should have_many(:feedbacks).dependent(:destroy) }

      # Testing has_one_attached for ActiveStorage
      it { should have_one_attached(:image) }
    end  end

  # describe ".ransackable_attributes" do
  #   expect(User.ransackable_attributes).to include("email", "phone", "user_name")
  # end

  # describe ".ransackable_associations" do
  #   expect(User.ransackable_associations).to include("addresses", "orders")
  # end
end
