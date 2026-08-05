require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "gamebookがなければ無効である" do
    item = items(:one)
    item.gamebook = nil

    assert_not item.valid?
  end
end
