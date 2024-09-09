FactoryBot.define do
  factory :user do
    user_name { "Test User" }
    email { "test@test.com" }
    password { "password" }
    phone { "0766257688" }
    role { 0 }
  end
end
