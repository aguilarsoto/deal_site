require 'test_helper'

class PublisherTest < ActiveSupport::TestCase
  test "can't have self as parent" do
    publisher = FactoryGirl.create(:publisher)
    assert publisher.valid?

    publisher.parent = publisher
    assert !publisher.valid?

    second_publisher = FactoryGirl.create(:publisher)
    publisher.parent = second_publisher
    assert publisher.valid?

    publisher.save!
  end

  context "publishers name" do
    setup do
      @publisher = FactoryGirl.create(:publisher, :name => 'boston', :theme => 'lala')
      @second_publisher = FactoryGirl.create(:publisher, :name => "foobar", :theme => 'baz')
      @publisher.parent = @second_publisher 
    end
    should "return parent_name when parent is available" do
      assert_equal @publisher.parent_name, "foobar"
      assert_nil @second_publisher.parent_name
    end
    should "full_name is an agregation of my name and my parents name if available if not just my name" do
      assert_equal @publisher.full_name, "foobar boston"
      assert_equal @second_publisher.full_name, "foobar"
    end
    should "delegate parent_theme" do
      assert_equal @publisher.parent_theme, "baz"
      assert_nil @second_publisher.parent_theme
    end
  end
end
