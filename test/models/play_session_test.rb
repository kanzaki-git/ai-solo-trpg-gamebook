require "test_helper"

class PlaySessionTest < ActiveSupport::TestCase
  test "関連するユーザー、ゲームブック、現在のシーンを取得できる" do
    play_session = play_sessions(:one)

    assert_equal users(:one), play_session.user
    assert_equal gamebooks(:one), play_session.gamebook
    assert_equal scenes(:one), play_session.current_scene
  end

  test "プレイ中はエンディングシーンが未設定でも有効である" do
    play_session = play_sessions(:one)

    assert_nil play_session.ending_scene
    assert play_session.valid?
  end

  test "完了済みのプレイからエンディングシーンを取得できる" do
    play_session = play_sessions(:two)

    assert_equal scenes(:two), play_session.ending_scene
  end

  test "プレイ状態をenumで判定できる" do
    assert_predicate play_sessions(:one), :playing?
    assert_predicate play_sessions(:two), :completed?
  end

  test "新しいプレイの初期状態はplayingである" do
    play_session = PlaySession.new

    assert_predicate play_session, :playing?
  end

  test "開始日時がない場合は無効である" do
    play_session = play_sessions(:one)
    play_session.started_at = nil

    assert_not play_session.valid?
    assert play_session.errors.added?(:started_at, :blank)
  end
end
