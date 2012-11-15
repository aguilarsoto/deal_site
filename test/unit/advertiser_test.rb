require "test_helper"

class AdvertiserTest < ActiveSupport::TestCase
  test "constraints" do
    publisher = FactoryGirl.create(:publisher)
    publisher.advertisers.create(:name => "Burgerville")
    advertiser = publisher.advertisers.build(:name => "Burgerville")
    assert !advertiser.valid?, "Should not allow duplicate names"

    advertiser.name = "In N' Out Burger"
    assert advertiser.valid?, "Should allow multiple advertisers with unique names on the same publisher"
    
    another_publisher = FactoryGirl.create(:publisher)
    another_advertiser = another_publisher.advertisers.build(:name => "Burgerville")
    assert advertiser.valid?, "Should allow multiple advertisers with the same name on the different publisher"
  end
end
