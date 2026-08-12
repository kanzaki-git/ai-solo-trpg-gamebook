require "test_helper"

class PlaySessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Play Session Test User",
      email: "play-session-test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @other_user = User.create!(
      name: "Other Play Session User",
      email: "other-play-session@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "未ログイン時はプレイを開始できない" do
    gamebook = create_gamebook(user: @user)
    create_start_scene(gamebook: gamebook)

    assert_no_difference "PlaySession.count" do
      post gamebook_play_sessions_path(gamebook)
    end

    assert_redirected_to login_path
  end

  test "ログイン中は最初からプレイを開始できる" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    login_as(@user)

    assert_difference "PlaySession.count", 1 do
      post gamebook_play_sessions_path(gamebook)
    end

    play_session = PlaySession.last

    assert_equal @user, play_session.user
    assert_equal gamebook, play_session.gamebook
    assert_equal start_scene, play_session.current_scene
    assert_predicate play_session, :playing?
    assert_not_nil play_session.started_at
    assert_redirected_to play_session_path(play_session)
  end

  test "ログイン中は自分のプレイ画面を表示できる" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)
    next_scene = gamebook.scenes.create!(
      scene_key: "forest_path",
      title: "森の奥",
      body: "あなたは森の奥へ進んだ。",
      situation: "木々に囲まれている",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    start_scene.choices.create!(
      next_scene: next_scene,
      text: "森の奥へ進む",
      result_text: "あなたは慎重に森の奥へ進んだ。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    item = gamebook.items.create!(
      key: "old_lantern",
      name: "古びたランタン",
      description: "暗い場所を照らせるランタン"
    )

    play_session.play_session_items.create!(
      item: item
    )

    login_as(@user)
    get play_session_path(play_session)

    assert_response :success
    assert_includes response.body, "物語の始まり"
    assert_includes response.body, "あなたは深い森の入口に立っている。"
    assert_includes response.body, "森の奥へ進む"
    assert_includes response.body, "古びたランタン"
  end

  test "現在のシーンに属していない選択肢では進められない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    other_scene = gamebook.scenes.create!(
      scene_key: "other_scene",
      title: "別のシーン",
      body: "現在地とは異なるシーン。",
      situation: "別の場所にいる",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    next_scene = gamebook.scenes.create!(
      scene_key: "next_scene",
      title: "次のシーン",
      body: "本来はここへ進む。",
      situation: "物語の続き",
      scene_type: :exploration,
      is_start: false,
      position: 3
    )

    other_scene_choice = other_scene.choices.create!(
      next_scene: next_scene,
      text: "別のシーンにある選択肢",
      result_text: "次のシーンへ進んだ。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_no_difference "PlayHistory.count" do
      patch advance_play_session_path(play_session),
            params: { choice_id: other_scene_choice.id }
    end

    assert_response :not_found
    assert_equal start_scene, play_session.reload.current_scene
  end

  test "未ログイン状態ではプレイを進められない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "next_scene",
      title: "次のシーン",
      body: "次のシーンの本文。",
      situation: "物語が進んだ",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "先へ進む",
      result_text: "次のシーンへ進んだ。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    assert_no_difference "PlayHistory.count" do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    assert_redirected_to login_path
    assert_equal start_scene, play_session.reload.current_scene
  end

  test "必須フラグを所持している選択肢だけを表示する" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "hidden_room",
      title: "隠し部屋",
      body: "隠し部屋へ入った。",
      situation: "薄暗い部屋にいる",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    owned_flag = gamebook.flags.create!(
      key: "found_key",
      name: "鍵を発見した",
      description: "隠し部屋の鍵を持っている"
    )

    missing_flag = gamebook.flags.create!(
      key: "learned_password",
      name: "合言葉を知った",
      description: "秘密の合言葉を知っている"
    )

    available_choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "鍵を使って扉を開ける",
      result_text: "鍵を使って扉を開けた。",
      position: 1
    )

    unavailable_choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "合言葉を唱える",
      result_text: "合言葉を唱えた。",
      position: 2
    )

    available_choice.choice_flag_rules.create!(
      flag: owned_flag,
      rule_type: :required
    )

    unavailable_choice.choice_flag_rules.create!(
      flag: missing_flag,
      rule_type: :required
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    play_session.play_session_flags.create!(
      flag: owned_flag
    )

    login_as(@user)
    get play_session_path(play_session)

    assert_response :success
    assert_includes response.body, "鍵を使って扉を開ける"
    assert_not_includes response.body, "合言葉を唱える"
  end

  test "未ログイン時はプレイ画面を表示できない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    get play_session_path(play_session)

    assert_redirected_to login_path
  end

  test "必須フラグを所持していない選択肢では進めない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "hidden_room",
      title: "隠し部屋",
      body: "隠し部屋へ入った。",
      situation: "薄暗い部屋にいる",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    required_flag = gamebook.flags.create!(
      key: "found_key",
      name: "鍵を発見した",
      description: "隠し部屋の鍵を持っている"
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "鍵を使って扉を開ける",
      result_text: "鍵を使って扉を開けた。",
      position: 1
    )

    choice.choice_flag_rules.create!(
      flag: required_flag,
      rule_type: :required
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_no_difference "PlayHistory.count" do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    assert_equal start_scene, play_session.reload.current_scene
    assert_redirected_to play_session_path(play_session)
    assert_equal "この選択肢は現在選べません。", flash[:alert]
  end

  test "選択肢を選ぶとフラグを追加する" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "after_investigation",
      title: "調査を終えて",
      body: "あなたは手がかりを見つけた。",
      situation: "新しい事実が判明した",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    found_clue_flag = gamebook.flags.create!(
      key: "found_clue",
      name: "手がかりを発見した",
      description: "事件につながる手がかりを見つけた"
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "周囲を詳しく調べる",
      result_text: "周囲を調べ、手がかりを発見した。",
      position: 1
    )

    choice.choice_flag_rules.create!(
      flag: found_clue_flag,
      rule_type: :add
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_difference "PlaySessionFlag.count", 1 do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    assert_includes play_session.reload.flags, found_clue_flag
    assert_equal next_scene, play_session.current_scene
  end

  test "選択肢を選ぶとフラグを削除する" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "after_unlocking",
      title: "扉の向こう",
      body: "あなたは扉の向こうへ進んだ。",
      situation: "鍵を使い終えた",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    used_key_flag = gamebook.flags.create!(
      key: "has_key",
      name: "鍵を所持している",
      description: "扉を開けるための鍵を持っている"
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "鍵を使って扉を開ける",
      result_text: "鍵を使って扉を開けた。",
      position: 1
    )

    choice.choice_flag_rules.create!(
      flag: used_key_flag,
      rule_type: :remove
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    play_session.play_session_flags.create!(
      flag: used_key_flag
    )

    login_as(@user)

    assert_difference "PlaySessionFlag.count", -1 do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    play_session.reload

    assert_not_includes play_session.flags, used_key_flag
    assert_equal next_scene, play_session.current_scene
  end

  test "他のユーザーのプレイ画面は表示できない" do
    gamebook = create_gamebook(user: @other_user)
    start_scene = create_start_scene(gamebook: gamebook)

    play_session = @other_user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)
    get play_session_path(play_session)

    assert_response :not_found
  end

  test "開始シーンがない場合はプレイを開始できない" do
    gamebook = create_gamebook(user: @user)

    login_as(@user)

    assert_no_difference "PlaySession.count" do
      post gamebook_play_sessions_path(gamebook)
    end

    assert_redirected_to gamebook_path(gamebook)
    assert_equal(
      "開始シーンが見つからないため、プレイを開始できません。",
      flash[:alert]
    )
  end

test "他のユーザーのゲームブックではプレイを開始できない" do
    gamebook = create_gamebook(user: @other_user)
    create_start_scene(gamebook: gamebook)

    login_as(@user)

    assert_no_difference "PlaySession.count" do
      post gamebook_play_sessions_path(gamebook)
    end

    assert_response :not_found
  end

  test "選択肢を選ぶと履歴を保存して次のシーンへ進む" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "forest_path",
      title: "森の奥",
      body: "あなたは森の奥へ進んだ。",
      situation: "木々に囲まれている",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "森の奥へ進む",
      result_text: "あなたは慎重に森の奥へ進んだ。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_difference "PlayHistory.count", 1 do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    play_session.reload
    play_history = PlayHistory.last

    assert_equal next_scene, play_session.current_scene
    assert_equal play_session, play_history.play_session
    assert_equal start_scene, play_history.scene
    assert_equal choice, play_history.choice
    assert_not_nil play_history.visited_at
    assert_redirected_to play_session_path(play_session)
    assert_equal choice.result_text, flash[:notice]
  end

  test "選択肢を選ぶと所持品を追加する" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "found_lantern",
      title: "ランタンを発見",
      body: "あなたは古びたランタンを見つけた。",
      situation: "ランタンを手に入れた",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    lantern = gamebook.items.create!(
      key: "old_lantern",
      name: "古びたランタン",
      description: "暗い場所を照らせるランタン"
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "ランタンを拾う",
      result_text: "古びたランタンを拾った。",
      position: 1
    )

    choice.choice_item_rules.create!(
      item: lantern,
      rule_type: :add
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_difference "PlaySessionItem.count", 1 do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    play_session.reload

    assert_includes play_session.items, lantern
    assert_equal next_scene, play_session.current_scene
  end

  test "選択肢を選ぶと所持品を削除する" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "opened_door",
      title: "開かれた扉",
      body: "鍵を使うと、扉がゆっくりと開いた。",
      situation: "扉の先へ進める",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    key_item = gamebook.items.create!(
      key: "rusty_key",
      name: "錆びた鍵",
      description: "古い扉を開けるための鍵"
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "錆びた鍵を使って扉を開ける",
      result_text: "錆びた鍵を使って扉を開けた。",
      position: 1
    )

    choice.choice_item_rules.create!(
      item: key_item,
      rule_type: :remove
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    play_session.play_session_items.create!(
      item: key_item
    )

    login_as(@user)

    assert_difference "PlaySessionItem.count", -1 do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    play_session.reload

    assert_not_includes play_session.items, key_item
    assert_equal next_scene, play_session.current_scene
  end

  test "必須所持品を持っていない選択肢は実行できない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "locked_room",
      title: "鍵のかかった部屋",
      body: "扉には頑丈な鍵がかかっている。",
      situation: "鍵がなければ先へ進めない",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    key_item = gamebook.items.create!(
      key: "silver_key",
      name: "銀の鍵",
      description: "鍵のかかった扉を開けるための鍵"
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "銀の鍵で扉を開ける",
      result_text: "銀の鍵を使って扉を開けた。",
      position: 1
    )

    choice.choice_item_rules.create!(
      item: key_item,
      rule_type: :required
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_no_difference "PlayHistory.count" do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    play_session.reload

    assert_redirected_to play_session_path(play_session)
    assert_equal start_scene, play_session.current_scene
    assert_not_includes play_session.items, key_item
  end

  test "保存された現在のシーンからプレイを再開できる" do
    gamebook = create_gamebook(
      user: @user,
    )

    saved_scene = gamebook.scenes.create!(
      scene_key: "saved_scene",
      title: "保存されたシーン",
      body: "前回保存された場面から再開する。",
      situation: "冒険の途中",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: saved_scene,
      status: :playing,
      started_at: 1.hour.ago
    )

    login_as(@user)

    assert_no_difference "PlaySession.count" do
      get play_session_path(play_session)
    end

    assert_response :success
    assert_select "body", text: /保存されたシーン/
    assert_select "body", text: /前回保存された場面から再開する。/
  end

  test "再開しても保存済みのフラグと所持品と履歴が維持される" do
    gamebook = create_gamebook(user: @user)

    saved_scene = gamebook.scenes.create!(
      scene_key: "saved_state_scene",
      title: "状態保存確認シーン",
      body: "保存状態を確認する。",
      situation: "冒険の途中",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: saved_scene,
      status: :playing,
      started_at: 1.hour.ago
    )

    saved_flag = gamebook.flags.create!(
      key: "found_clue",
      name: "手がかりを発見",
      description: "重要な手がかりを発見している"
    )

    saved_item = gamebook.items.create!(
      key: "old_key",
      name: "古びた鍵",
      description: "古い扉を開けるための鍵"
    )

    play_session.play_session_flags.create!(flag: saved_flag)
    play_session.play_session_items.create!(item: saved_item)

    saved_history = play_session.play_histories.create!(
      scene: saved_scene,
      visited_at: 30.minutes.ago
    )

    login_as(@user)

    assert_no_difference(
      [
        "PlaySession.count",
        "PlaySessionFlag.count",
        "PlaySessionItem.count",
        "PlayHistory.count"
      ]
    ) do
      get play_session_path(play_session)
    end

    assert_response :success
    assert_select "body", text: /古びた鍵/

    assert PlaySessionFlag.exists?(
      play_session: play_session,
      flag: saved_flag
    )

    assert PlaySessionItem.exists?(
      play_session: play_session,
      item: saved_item
    )

    assert PlayHistory.exists?(id: saved_history.id)
  end

  test "他のユーザーのプレイは進められない" do
    gamebook = create_gamebook(user: @other_user)
    start_scene = create_start_scene(gamebook: gamebook)

    next_scene = gamebook.scenes.create!(
      scene_key: "forest_path",
      title: "森の奥",
      body: "あなたは森の奥へ進んだ。",
      situation: "木々に囲まれている",
      scene_type: :exploration,
      is_start: false,
      position: 2
    )

    choice = start_scene.choices.create!(
      next_scene: next_scene,
      text: "森の奥へ進む",
      result_text: "あなたは慎重に森の奥へ進んだ。",
      position: 1
    )

    play_session = @other_user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    assert_no_difference "PlayHistory.count" do
      patch advance_play_session_path(play_session),
            params: { choice_id: choice.id }
    end

    assert_response :not_found
    assert_equal start_scene, play_session.reload.current_scene
  end

  test "エンディングに到達するとプレイが完了する" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    ending_scene = gamebook.scenes.create!(
      scene_key: "true_ending",
      title: "真実の結末",
      body: "あなたは事件の真相へたどり着いた。",
      situation: "物語が完結した",
      scene_type: :ending,
      is_start: false,
      is_ending: true,
      ending_type: :true,
      position: 2
    )

    choice = start_scene.choices.create!(
      next_scene: ending_scene,
      text: "事件の真相を明らかにする",
      result_text: "すべての謎が解き明かされた。",
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    patch advance_play_session_path(play_session),
          params: { choice_id: choice.id }

    play_session.reload

    assert_equal ending_scene, play_session.current_scene
    assert_equal ending_scene, play_session.ending_scene
    assert_predicate play_session, :completed?
    assert_not_nil play_session.completed_at
    assert_redirected_to result_play_session_path(play_session)
    assert_equal choice.result_text, flash[:notice]
  end

  test "完了したプレイの結果画面を表示できる" do
    gamebook = create_gamebook(user: @user)

    ending_scene = gamebook.scenes.create!(
      scene_key: "true_ending",
      title: "真実の結末",
      body: "あなたは事件の真相へたどり着いた。",
      situation: "物語が完結した",
      scene_type: :ending,
      is_start: false,
      is_ending: true,
      ending_type: :true,
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: ending_scene,
      ending_scene: ending_scene,
      status: :completed,
      started_at: 30.minutes.ago,
      completed_at: Time.current
    )

    login_as(@user)

    get result_play_session_path(play_session)

    assert_response :success
    assert_includes response.body, gamebook.title
    assert_includes response.body, "物語の結末"
    assert_includes response.body, "真実の結末"
    assert_includes response.body, "トゥルーエンディング"
    assert_includes response.body, "あなたは事件の真相へたどり着いた。"
    assert_includes response.body, "ゲームブック一覧へ戻る"
    assert_includes response.body, "最初から遊び直す"
  end

  test "完了したゲームブックを最初から遊び直せる" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    ending_scene = gamebook.scenes.create!(
      scene_key: "true_ending",
      title: "真実の結末",
      body: "あなたは事件の真相へたどり着いた。",
      situation: "物語が完結した",
      scene_type: :ending,
      is_start: false,
      is_ending: true,
      ending_type: :true,
      position: 2
    )

    completed_play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: ending_scene,
      ending_scene: ending_scene,
      status: :completed,
      started_at: 30.minutes.ago,
      completed_at: Time.current
    )

    acquired_flag = gamebook.flags.create!(
      key: "found_truth",
      name: "真相を発見した",
      description: "事件の真相を明らかにした"
    )

    acquired_item = gamebook.items.create!(
      key: "mysterious_key",
      name: "謎の鍵",
      description: "事件の途中で手に入れた鍵"
    )

    completed_play_session.play_session_flags.create!(
      flag: acquired_flag
    )

    completed_play_session.play_session_items.create!(
      item: acquired_item
    )

    play_history = completed_play_session.play_histories.create!(
      scene: ending_scene,
      visited_at: Time.current
    )

    login_as(@user)

    assert_difference "PlaySession.count", 1 do
      assert_no_difference(
        [
          "PlaySessionFlag.count",
          "PlaySessionItem.count",
          "PlayHistory.count"
        ]
      ) do
        post gamebook_play_sessions_path(gamebook)
      end
    end

    new_play_session = PlaySession.order(:id).last

    assert_not_equal completed_play_session, new_play_session
    assert_equal @user, new_play_session.user
    assert_equal gamebook, new_play_session.gamebook
    assert_equal start_scene, new_play_session.current_scene
    assert_predicate new_play_session, :playing?
    assert_nil new_play_session.ending_scene
    assert_nil new_play_session.completed_at
    assert_empty new_play_session.flags
    assert_empty new_play_session.items
    assert_empty new_play_session.play_histories
    assert_redirected_to play_session_path(new_play_session)

    completed_play_session.reload

    assert_predicate completed_play_session, :completed?
    assert_equal ending_scene, completed_play_session.current_scene
    assert_equal ending_scene, completed_play_session.ending_scene
    assert_includes completed_play_session.flags, acquired_flag
    assert_includes completed_play_session.items, acquired_item
    assert PlayHistory.exists?(id: play_history.id)
  end

  test "未完了のプレイでは結果画面を表示できない" do
    gamebook = create_gamebook(user: @user)
    start_scene = create_start_scene(gamebook: gamebook)

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: start_scene,
      status: :playing,
      started_at: Time.current
    )

    login_as(@user)

    get result_play_session_path(play_session)

    assert_redirected_to play_session_path(play_session)
    assert_equal "このプレイはまだ完了していません。", flash[:alert]
  end

  test "未ログイン時は結果画面を表示できない" do
    gamebook = create_gamebook(user: @user)

    ending_scene = gamebook.scenes.create!(
      scene_key: "true_ending",
      title: "真実の結末",
      body: "あなたは事件の真相へたどり着いた。",
      situation: "物語が完結した",
      scene_type: :ending,
      is_start: false,
      is_ending: true,
      ending_type: :true,
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: ending_scene,
      ending_scene: ending_scene,
      status: :completed,
      started_at: 30.minutes.ago,
      completed_at: Time.current
    )

    get result_play_session_path(play_session)

    assert_redirected_to login_path
  end

  test "他のユーザーの結果画面を表示できない" do
    gamebook = create_gamebook(user: @user)

    ending_scene = gamebook.scenes.create!(
      scene_key: "true_ending",
      title: "真実の結末",
      body: "あなたは事件の真相へたどり着いた。",
      situation: "物語が完結した",
      scene_type: :ending,
      is_start: false,
      is_ending: true,
      ending_type: :true,
      position: 1
    )

    play_session = @user.play_sessions.create!(
      gamebook: gamebook,
      current_scene: ending_scene,
      ending_scene: ending_scene,
      status: :completed,
      started_at: 30.minutes.ago,
      completed_at: Time.current
    )

    login_as(@other_user)

    get result_play_session_path(play_session)

    assert_response :not_found
  end

  private

  def login_as(user)
    post login_path, params: {
      email: user.email,
      password: "password123"
    }
  end

  def create_gamebook(user:)
    user.gamebooks.create!(
      title: "プレイテスト用ゲームブック",
      summary: "プレイテスト用の概要",
      genre: "ファンタジー",
      world_setting: "魔法が存在する世界",
      tone: "シリアス",
      difficulty: "普通",
      play_time: 30,
      generation_status: :completed
    )
  end

  def create_start_scene(gamebook:)
    gamebook.scenes.create!(
      scene_key: "start",
      title: "物語の始まり",
      body: "あなたは深い森の入口に立っている。",
      situation: "冒険の開始地点",
      scene_type: :introduction,
      is_start: true,
      position: 1
    )
  end
end
