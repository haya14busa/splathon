# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    event
    name { "Team-#{Random.rand(1..10)}" }
    company_name { Faker::Company.name }
    short_comment { Faker::Lorem.sentence }
  end
end
