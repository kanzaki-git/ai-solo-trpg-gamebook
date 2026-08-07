require "test_helper"

class SceneTest < ActiveSupport::TestCase
  test "scene_typeの値が正しく定義されていること" do
    expected_scene_types = {
      "introduction" => 0,
      "exploration" => 1,
      "change" => 2,
      "summary" => 3,
      "climax" => 4,
      "ending" => 5
    }

    assert_equal expected_scene_types, Scene.scene_types
  end

  test "ending_typeの値が正しく定義されていること" do
    expected_ending_types = {
      "bad" => 0,
      "normal" => 1,
      "true" => 2
    }

    assert_equal expected_ending_types, Scene.ending_types
  end
end
