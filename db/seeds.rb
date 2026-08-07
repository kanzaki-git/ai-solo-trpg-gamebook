sample_user = User.find_or_initialize_by(email: "sample@example.com")

sample_user.assign_attributes(
  name: "サンプルユーザー",
  password: "password",
  password_confirmation: "password"
)

sample_user.save!

sample_gamebook = Gamebook.find_or_initialize_by(
  user: sample_user,
  title: "霧の港町と灯台の秘密"
)

sample_gamebook.assign_attributes(
  summary: "霧に包まれた港町で起きている失踪事件を調査し、古い灯台に隠された秘密を追う物語です。",
  genre: "ミステリー",
  world_setting: "古い灯台のある霧深い港町",
  tone: "不穏で幻想的",
  difficulty: "普通",
  play_time: 30,
  generation_status: :completed,
  generated_at: Time.current
)

sample_gamebook.save!

puts "動作確認用ユーザーを登録しました。"
puts "サンプルゲームブックを登録しました。"

sample_flags = [
  {
    key: "heard_from_residents",
    name: "港町の住民から話を聞いた",
    description: "港町の住民から失踪事件に関する情報を得たことを表します。"
  },
  {
    key: "learned_lighthouse_secret",
    name: "灯台の秘密を知った",
    description: "古い灯台に隠された秘密を知ったことを表します。"
  },
  {
    key: "discovered_by_guard",
    name: "見張りに発見された",
    description: "灯台を調査中に見張りに発見されたことを表します。"
  }
]

sample_flags.each do |attributes|
  flag = sample_gamebook.flags.find_or_initialize_by(key: attributes[:key])
  flag.assign_attributes(attributes)
  flag.save!
end

sample_items = [
  {
    key: "old_lantern",
    name: "古びたランタン",
    description: "暗い場所を照らすために使える古いランタンです。"
  },
  {
    key: "brass_key",
    name: "真鍮の鍵",
    description: "灯台の中にある古い扉を開けるための鍵です。"
  },
  {
    key: "lighthouse_keeper_diary",
    name: "灯台守の日記",
    description: "灯台で起きた出来事と秘密が記された日記です。"
  }
]

sample_items.each do |attributes|
  item = sample_gamebook.items.find_or_initialize_by(key: attributes[:key])
  item.assign_attributes(attributes)
  item.save!
end

puts "フラグを登録しました。"
puts "所持品を登録しました。"

sample_scenes = [
  {
    scene_key: "harbor_entrance",
    title: "霧に包まれた港町",
    body: "あなたは、相次ぐ失踪事件を調査するため、霧に包まれた港町へやってきた。港には不安そうな住民たちと、町を見下ろす古い灯台が見える。",
    situation: "港町に到着し、調査を始める場面です。",
    scene_type: :introduction,
    is_start: true,
    is_ending: false,
    ending_type: nil,
    position: 1
  },
  {
    scene_key: "town_square",
    title: "港町の広場",
    body: "広場では住民たちが失踪事件について噂している。話を聞けば、事件につながる情報を得られるかもしれない。",
    situation: "住民から情報を集める探索場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 2
  },
  {
    scene_key: "old_warehouse",
    title: "港の古い倉庫",
    body: "使われなくなった倉庫の中には、古びたランタンと灯台へ運ばれた荷物の記録が残されていた。",
    situation: "灯台の調査に役立つ所持品を発見する場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 3
  },
  {
    scene_key: "lighthouse_entrance",
    title: "古い灯台の入口",
    body: "灯台の入口は固く閉ざされている。扉には古い鍵穴があり、周囲には見張りの足音が響いている。",
    situation: "集めた情報や所持品によって進み方が変わる場面です。",
    scene_type: :change,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 4
  },
  {
    scene_key: "lighthouse_inside",
    title: "灯台の内部",
    body: "灯台の中は暗く、螺旋階段が上へ続いている。壁には、誰かが急いで残したような印が刻まれている。",
    situation: "ランタンを使い、灯台の内部を探索する場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 5
  },
  {
    scene_key: "keeper_room",
    title: "灯台守の部屋",
    body: "机の引き出しから灯台守の日記が見つかった。そこには、失踪事件と灯台に隠された秘密が記されている。",
    situation: "事件の真相につながる情報を入手する場面です。",
    scene_type: :summary,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 6
  },
  {
    scene_key: "underground_chamber",
    title: "灯台地下の隠し部屋",
    body: "日記に記された仕掛けを操作すると、地下へ続く階段が現れた。その先には、事件の真相を知る人物が待っていた。",
    situation: "集めた情報と所持品を使って真相に迫る場面です。",
    scene_type: :climax,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 7
  },
  {
    scene_key: "bad_ending",
    title: "霧の中の失踪",
    body: "十分な準備をしないまま灯台へ踏み込んだあなたは、深い霧の中で帰り道を見失った。その後、あなたの姿を見た者はいなかった。",
    situation: "調査や準備が不足していた場合の結末です。",
    scene_type: :ending,
    is_start: false,
    is_ending: true,
    ending_type: :bad,
    position: 8
  },
  {
    scene_key: "normal_ending",
    title: "事件の終結",
    body: "あなたは事件の一部を明らかにし、失踪事件を止めることに成功した。しかし、灯台に残された謎のすべてが解明されたわけではなかった。",
    situation: "事件を解決したものの、真相の一部が残る結末です。",
    scene_type: :ending,
    is_start: false,
    is_ending: true,
    ending_type: :normal,
    position: 9
  },
  {
    scene_key: "true_ending",
    title: "灯台の真実",
    body: "灯台守の日記と集めた証拠によって、あなたは失踪事件の真相を完全に解明した。霧は晴れ、港町には久しぶりに朝日が差し込んだ。",
    situation: "必要な情報と所持品を集めた場合に到達する真の結末です。",
    scene_type: :ending,
    is_start: false,
    is_ending: true,
    ending_type: :true,
    position: 10
  }
]

sample_scenes.each do |attributes|
  scene = sample_gamebook.scenes.find_or_initialize_by(
    scene_key: attributes[:scene_key]
  )

  scene.assign_attributes(attributes)
  scene.save!
end

puts "シーンを登録しました。"

scenes_by_key = sample_gamebook.scenes.index_by(&:scene_key)

sample_choices = [
  {
    scene_key: "harbor_entrance",
    next_scene_key: "town_square",
    text: "港町の住民から話を聞く",
    result_text: "あなたは港町の広場へ向かい、住民から失踪事件について話を聞くことにした。",
    position: 1
  },
  {
    scene_key: "harbor_entrance",
    next_scene_key: "old_warehouse",
    text: "港の古い倉庫を調べる",
    result_text: "あなたは人目を避けながら、使われなくなった古い倉庫へ向かった。",
    position: 2
  },
  {
    scene_key: "harbor_entrance",
    next_scene_key: "bad_ending",
    text: "準備をせず、すぐに灯台へ向かう",
    result_text: "あなたは十分な情報も道具も持たないまま、深い霧の中へ足を踏み入れた。",
    position: 3
  },
  {
    scene_key: "town_square",
    next_scene_key: "old_warehouse",
    text: "住民の話を手掛かりに倉庫を調べる",
    result_text: "住民の話から、古い倉庫に灯台へつながる手掛かりがあると分かった。",
    position: 1
  },
  {
    scene_key: "town_square",
    next_scene_key: "lighthouse_entrance",
    text: "住民から聞いた情報を頼りに灯台へ向かう",
    result_text: "あなたは住民から得た情報を頼りに、古い灯台へ向かった。",
    position: 2
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "town_square",
    text: "ランタンを持って広場へ戻る",
    result_text: "古びたランタンを手に入れたあなたは、さらに情報を集めるため広場へ戻った。",
    position: 1
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "lighthouse_entrance",
    text: "見つけたランタンを持って灯台へ向かう",
    result_text: "あなたは古びたランタンを手に、霧の中にそびえる灯台へ向かった。",
    position: 2
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "lighthouse_inside",
    text: "真鍮の鍵を使って扉を開ける",
    result_text: "真鍮の鍵を差し込むと、重い音を立てて灯台の扉が開いた。",
    position: 1
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "normal_ending",
    text: "集めた情報を町の人々へ伝える",
    result_text: "あなたは無理に灯台へ入らず、集めた情報を町の人々へ伝えることにした。",
    position: 2
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "bad_ending",
    text: "見張りを無視して扉を壊す",
    result_text: "大きな音が霧の中へ響き渡り、見張りにあなたの存在を知られてしまった。",
    position: 3
  },
  {
    scene_key: "lighthouse_inside",
    next_scene_key: "keeper_room",
    text: "ランタンで周囲を照らして進む",
    result_text: "ランタンの光が暗闇を払い、灯台守の部屋へ続く通路を照らした。",
    position: 1
  },
  {
    scene_key: "lighthouse_inside",
    next_scene_key: "bad_ending",
    text: "暗闇の中を手探りで進む",
    result_text: "暗闇の中で足を踏み外し、あなたは霧の底へと消えていった。",
    position: 2
  },
  {
    scene_key: "keeper_room",
    next_scene_key: "underground_chamber",
    text: "灯台守の日記を読み、隠し部屋を探す",
    result_text: "日記の記述を手掛かりに壁を調べると、地下へ続く隠し階段が現れた。",
    position: 1
  },
  {
    scene_key: "keeper_room",
    next_scene_key: "normal_ending",
    text: "日記を持って町へ戻る",
    result_text: "あなたは危険を冒さず、見つけた日記を証拠として町へ持ち帰った。",
    position: 2
  },
  {
    scene_key: "underground_chamber",
    next_scene_key: "true_ending",
    text: "集めた証拠を示して真相を明らかにする",
    result_text: "集めた情報と証拠がつながり、失踪事件の真相がついに明らかになった。",
    position: 1
  },
  {
    scene_key: "underground_chamber",
    next_scene_key: "normal_ending",
    text: "危険を感じて地下から引き返す",
    result_text: "あなたはこれ以上の追及を諦め、判明した事実だけを町へ持ち帰った。",
    position: 2
  }
]

sample_choices.each do |attributes|
  scene = scenes_by_key.fetch(attributes[:scene_key])
  next_scene = scenes_by_key.fetch(attributes[:next_scene_key])

  choice = scene.choices.find_or_initialize_by(
    position: attributes[:position]
  )

  choice.assign_attributes(
    next_scene: next_scene,
    text: attributes[:text],
    result_text: attributes[:result_text]
  )

  choice.save!
end

puts "選択肢を登録しました。"

flags_by_key = sample_gamebook.flags.index_by(&:key)
items_by_key = sample_gamebook.items.index_by(&:key)

sample_flag_rules = [
  {
    scene_key: "harbor_entrance",
    choice_position: 1,
    flag_key: "heard_from_residents",
    rule_type: :add
  },
  {
    scene_key: "old_warehouse",
    choice_position: 1,
    flag_key: "heard_from_residents",
    rule_type: :add
  },
  {
    scene_key: "town_square",
    choice_position: 1,
    flag_key: "heard_from_residents",
    rule_type: :required
  },
  {
    scene_key: "town_square",
    choice_position: 2,
    flag_key: "heard_from_residents",
    rule_type: :required
  },
  {
    scene_key: "lighthouse_entrance",
    choice_position: 3,
    flag_key: "discovered_by_guard",
    rule_type: :add
  },
  {
    scene_key: "keeper_room",
    choice_position: 1,
    flag_key: "learned_lighthouse_secret",
    rule_type: :add
  },
  {
    scene_key: "underground_chamber",
    choice_position: 1,
    flag_key: "learned_lighthouse_secret",
    rule_type: :required
  }
]

sample_flag_rules.each do |attributes|
  choice = scenes_by_key
             .fetch(attributes[:scene_key])
             .choices
             .find_by!(position: attributes[:choice_position])

  flag = flags_by_key.fetch(attributes[:flag_key])

  choice.choice_flag_rules.find_or_create_by!(
    flag: flag,
    rule_type: attributes[:rule_type]
  )
end

sample_item_rules = [
  {
    scene_key: "harbor_entrance",
    choice_position: 2,
    item_key: "old_lantern",
    rule_type: :add
  },
  {
    scene_key: "town_square",
    choice_position: 1,
    item_key: "old_lantern",
    rule_type: :add
  },
  {
    scene_key: "town_square",
    choice_position: 2,
    item_key: "brass_key",
    rule_type: :add
  },
  {
    scene_key: "lighthouse_entrance",
    choice_position: 1,
    item_key: "brass_key",
    rule_type: :required
  },
  {
    scene_key: "lighthouse_entrance",
    choice_position: 1,
    item_key: "brass_key",
    rule_type: :remove
  },
  {
    scene_key: "lighthouse_inside",
    choice_position: 1,
    item_key: "old_lantern",
    rule_type: :required
  },
  {
    scene_key: "keeper_room",
    choice_position: 1,
    item_key: "lighthouse_keeper_diary",
    rule_type: :add
  },
  {
    scene_key: "underground_chamber",
    choice_position: 1,
    item_key: "lighthouse_keeper_diary",
    rule_type: :required
  }
]

sample_item_rules.each do |attributes|
  choice = scenes_by_key
             .fetch(attributes[:scene_key])
             .choices
             .find_by!(position: attributes[:choice_position])

  item = items_by_key.fetch(attributes[:item_key])

  choice.choice_item_rules.find_or_create_by!(
    item: item,
    rule_type: attributes[:rule_type]
  )
end

puts "選択肢のフラグルールを登録しました。"
puts "選択肢の所持品ルールを登録しました。"
