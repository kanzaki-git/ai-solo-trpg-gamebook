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
    key: "manager_warning",
    name: "管理人の警告",
    description: "港湾管理人から、夜の灯台には近づかないよう警告されたことを表します。"
  },
  {
    key: "smuggling_ship_mark",
    name: "密輸船の印",
    description: "古い倉庫で、密輸船に使われていた印を発見したことを表します。"
  },
  {
    key: "fisherman_testimony",
    name: "漁師の証言",
    description: "老漁師から、灯台守が姿を消した夜の出来事を聞いたことを表します。"
  },
  {
    key: "erased_record",
    name: "消された記録",
    description: "港湾管理事務所で、意図的に消された船の入港記録を発見したことを表します。"
  },
  {
    key: "lighthouse_keeper_letter",
    name: "灯台守の手紙",
    description: "灯台守が失踪する前に残した手紙を読んだことを表します。"
  },
  {
    key: "stopped_clock_time",
    name: "止まった時計の時刻",
    description: "灯台の時計が、事件の起きた時刻で止まっていることを確認したことを表します。"
  }
]

sample_flags.each do |attributes|
  flag = sample_gamebook.flags.find_or_initialize_by(key: attributes[:key])
  flag.assign_attributes(attributes)
  flag.save!
end

sample_items = [
  {
    key: "brass_key",
    name: "真鍮の鍵",
    description: "灯台にある古い扉を開けるための、潮風でくすんだ鍵です。"
  },
  {
    key: "old_lantern",
    name: "古いランタン",
    description: "暗い場所を照らせますが、残っている燃料はわずかです。"
  },
  {
    key: "torn_chart",
    name: "破れた海図",
    description: "港の周辺と、通常の海図にはない航路が描かれています。"
  },
  {
    key: "silver_compass",
    name: "銀色の方位磁針",
    description: "霧の中でも不思議なほど正確に方角を示す方位磁針です。"
  }
]

sample_items.each do |attributes|
  item = sample_gamebook.items.find_or_initialize_by(key: attributes[:key])
  item.assign_attributes(attributes)
  item.save!
end

puts "フラグを登録しました。"
puts "所持品を登録しました。"

sample_gamebook.play_sessions.destroy_all

sample_gamebook.scenes.each do |scene|
  scene.choices.destroy_all
end

sample_gamebook.scenes.destroy_all

sample_gamebook.flags
               .where.not(key: sample_flags.pluck(:key))
               .destroy_all
sample_gamebook.items
               .where.not(key: sample_items.pluck(:key))
               .destroy_all

sample_scenes = [
  {
    scene_key: "harbor_arrival",
    title: "霧に包まれた港町",
    body: "相次ぐ失踪事件を調査するため、あなたは霧深い港町を訪れた。波止場の向こうでは古い灯台がかすみ、町のどこかから低い霧笛が響いている。",
    situation: "港町に到着し、最初の調査先を選ぶ場面です。",
    scene_type: :introduction,
    is_start: true,
    is_ending: false,
    ending_type: nil,
    position: 1
  },
  {
    scene_key: "harbor_office",
    title: "港湾管理事務所",
    body: "港湾管理人は灯台の話を避けようとするが、背後の書棚には古い入港記録が並んでいる。机の上には、夜の灯台へ近づくなと書かれた注意書きが置かれていた。",
    situation: "管理人の警告や港の記録から手掛かりを探す場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 2
  },
  {
    scene_key: "old_warehouse",
    title: "波止場の古い倉庫",
    body: "使われていない倉庫には、同じ印が焼き付けられた木箱と、まだ火のつく古いランタンが残されている。床には浜辺へ続く荷車の跡があった。",
    situation: "密輸船の痕跡と探索に役立つ道具を見つける場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 3
  },
  {
    scene_key: "anchor_and_foghorn",
    title: "酒場「錨と霧笛」",
    body: "酒場では失踪事件の噂がささやかれている。店の隅には、事件の夜に海へ出ていたという老漁師が一人で座っていた。",
    situation: "住民の噂を集め、次に会う人物や調査先を決める場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 4
  },
  {
    scene_key: "silent_fisherman",
    title: "沈黙する老漁師",
    body: "老漁師は長い沈黙の後、事件の夜に灯台から不審な船が離れたことを語る。そして、霧の海へ入るなら方位磁針を持てと警告した。",
    situation: "老漁師の証言を聞き、警告を受け入れるか決める場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 5
  },
  {
    scene_key: "erased_arrival_record",
    title: "消された入港記録",
    body: "古い帳簿には不自然な空白があり、破られた控えを重ねると、失踪事件の夜に正体不明の船が入港していたことが分かった。",
    situation: "密輸船と失踪事件を結ぶ記録を見つける場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 6
  },
  {
    scene_key: "shipwreck_beach",
    title: "難破船が眠る浜辺",
    body: "濃霧に覆われた浜辺には、古い難破船の残骸が横たわっている。手掛かりを正しく使えば、船内から秘密の航路を示す海図を見つけられそうだ。",
    situation: "集めた情報や方位磁針を使って難破船を調査する場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 7
  },
  {
    scene_key: "keeper_house",
    title: "灯台守の家",
    body: "無人の家には書きかけの手紙が残されていた。床下からは真鍮の鍵がのぞき、棚には予備のランタンが置かれている。",
    situation: "灯台守が残した手紙と、灯台へ入るための道具を探す場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 8
  },
  {
    scene_key: "foghorn_night",
    title: "霧笛が鳴る夜",
    body: "日が沈むと霧はさらに濃くなり、灯台へ続く道は完全に見えなくなった。霧笛だけが、一定の間隔で闇の奥から響いてくる。",
    situation: "所持品を使って、安全に灯台へ近づく方法を選ぶ場面です。",
    scene_type: :change,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 9
  },
  {
    scene_key: "lighthouse_road",
    title: "霧の中の灯台道",
    body: "海図が示した道は崖沿いで二手に分かれている。一方は灯台の正面へ、もう一方は潮が引いた時だけ現れる地下道へ続いていた。",
    situation: "これまでに得た情報を使い、灯台への進入経路を選ぶ場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 10
  },
  {
    scene_key: "lighthouse_entrance",
    title: "閉ざされた灯台",
    body: "灯台の正面扉は固く閉ざされている。鍵穴のほか、壁際には荷物を運び込んだような傷と、古い通用口が見える。",
    situation: "鍵や情報を使って灯台へ入る場面です。",
    scene_type: :change,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 11
  },
  {
    scene_key: "spiral_staircase",
    title: "闇の螺旋階段",
    body: "灯台の内部には、上階へ続く螺旋階段が伸びている。足元は暗く、壁には灯台守が残したと思われる矢印が刻まれていた。",
    situation: "所持品や手紙を頼りに、暗い灯台内部を進む場面です。",
    scene_type: :exploration,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 12
  },
  {
    scene_key: "keeper_room",
    title: "灯台守の部屋",
    body: "机の上には灯台の運用日誌が残され、壁には港の地下を描いた図が貼られている。集めた証言や手紙と照らし合わせれば、隠し通路を見つけられそうだ。",
    situation: "集めた人物情報を整理し、真相へ続く道を探す場面です。",
    scene_type: :summary,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 13
  },
  {
    scene_key: "clock_room",
    title: "止まった時計室",
    body: "巨大な時計は、失踪事件が起きた夜と同じ時刻で止まっている。記録や手紙に書かれた時刻と一致しており、時計の裏には地下へ降りる仕掛けが隠されていた。",
    situation: "事件の時刻を確認し、地下への仕掛けを動かす場面です。",
    scene_type: :summary,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 14
  },
  {
    scene_key: "underground_passage",
    title: "灯台地下の通路",
    body: "湿った石造りの通路が三方向へ分かれている。壁には密輸船の印が刻まれ、遠くから波と人の話し声が聞こえてきた。",
    situation: "複数の手掛かりを使って、正しい地下通路を選ぶ場面です。",
    scene_type: :climax,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 15
  },
  {
    scene_key: "hidden_harbor",
    title: "霧に隠された港",
    body: "地下通路の先には、外から見えない小さな港があった。失踪した人々はここで密輸の荷運びを強いられ、沖には逃走用の船が停泊している。",
    situation: "集めた証拠を組み合わせ、事件の中心人物を追うか決める場面です。",
    scene_type: :climax,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 16
  },
  {
    scene_key: "confrontation",
    title: "真相との対決",
    body: "密輸団の首謀者は証拠を捨てて逃げようとしている。あなたが集めた記録、証言、手紙、所持品の組み合わせが、事件の真相を証明する最後の鍵となる。",
    situation: "これまでに集めた証拠を示し、最終的な結末を決める場面です。",
    scene_type: :climax,
    is_start: false,
    is_ending: false,
    ending_type: nil,
    position: 17
  },
  {
    scene_key: "bad_ending",
    title: "霧に呑まれた者",
    body: "危険を承知で先へ進んだあなたは、灯台を包む霧の中で方向感覚を失った。翌朝、港町にあなたが戻ることはなく、霧笛だけがいつまでも鳴り続けていた。",
    situation: "警告や手掛かりを使わず、危険な行動を選んだ結末です。",
    scene_type: :ending,
    is_start: false,
    is_ending: true,
    ending_type: :bad,
    position: 18
  },
  {
    scene_key: "normal_ending",
    title: "港町に戻った静けさ",
    body: "あなたが持ち帰った証拠によって失踪者は救出され、事件はいったん終結した。しかし密輸の全容と灯台守の行方には、まだ解けない謎が残っている。",
    situation: "事件を解決したものの、真相の一部が残った結末です。",
    scene_type: :ending,
    is_start: false,
    is_ending: true,
    ending_type: :normal,
    position: 19
  },
  {
    scene_key: "true_ending",
    title: "灯台の真実",
    body: "すべての証拠がつながり、密輸団の計画と、町の人々を守ろうとした灯台守の行動が明らかになった。失踪者は救われ、朝日が霧を払い、港町は本当の静けさを取り戻した。",
    situation: "複数の手掛かりを正しく組み合わせ、事件の全容を解明した結末です。",
    scene_type: :ending,
    is_start: false,
    is_ending: true,
    ending_type: :true,
    position: 20
  }
]

sample_scenes.each do |attributes|
  sample_gamebook.scenes.create!(attributes)
end

puts "シーンを登録しました。"

scenes_by_key = sample_gamebook.scenes.index_by(&:scene_key)
flags_by_key = sample_gamebook.flags.index_by(&:key)
items_by_key = sample_gamebook.items.index_by(&:key)

sample_choices = [
  {
    scene_key: "harbor_arrival",
    next_scene_key: "harbor_office",
    text: "港湾管理事務所で事件の記録を調べる",
    result_text: "あなたは港に残る公的な記録を確認するため、管理事務所へ向かった。",
    position: 1
  },
  {
    scene_key: "harbor_arrival",
    next_scene_key: "old_warehouse",
    text: "波止場の古い倉庫を調べる",
    result_text: "人目を避けながら、使われていない古い倉庫へ向かった。",
    position: 2
  },
  {
    scene_key: "harbor_arrival",
    next_scene_key: "anchor_and_foghorn",
    text: "酒場で失踪事件の噂を集める",
    result_text: "町の住民が集まる酒場なら、事件を知る人物に会えるかもしれない。",
    position: 3
  },
  {
    scene_key: "harbor_office",
    next_scene_key: "erased_arrival_record",
    text: "管理人の警告を聞き、夜間の入港記録を調べる",
    result_text: "管理人は、事件の夜から灯台に近づく者が消えていると警告した。",
    position: 1,
    add_flags: [ "manager_warning" ]
  },
  {
    scene_key: "harbor_office",
    next_scene_key: "old_warehouse",
    text: "灯台へ運ばれた荷物の記録を追う",
    result_text: "管理人の警告を胸に、荷物の送り先である古い倉庫へ向かった。",
    position: 2,
    add_flags: [ "manager_warning" ]
  },
  {
    scene_key: "harbor_office",
    next_scene_key: "anchor_and_foghorn",
    text: "書類よりも住民の証言を集める",
    result_text: "管理事務所を出たあなたは、住民が集まる酒場へ向かった。",
    position: 3
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "erased_arrival_record",
    text: "密輸船の印がある木箱を詳しく調べる",
    result_text: "木箱から密輸船の印を写し取り、そばにあった古いランタンも手に入れた。",
    position: 1,
    add_flags: [ "smuggling_ship_mark" ],
    add_items: [ "old_lantern" ]
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "anchor_and_foghorn",
    text: "古いランタンを持って酒場で聞き込む",
    result_text: "まだ使える古いランタンを手に取り、詳しい話を聞くため酒場へ向かった。",
    position: 2,
    add_items: [ "old_lantern" ]
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "shipwreck_beach",
    text: "密輸船の印を記録し、荷車の跡を追う",
    result_text: "木箱の印を記録したあなたは、荷車の跡が続く浜辺へ向かった。",
    position: 3,
    add_flags: [ "smuggling_ship_mark" ]
  },
  {
    scene_key: "anchor_and_foghorn",
    next_scene_key: "silent_fisherman",
    text: "事件の夜を知る老漁師に話を聞く",
    result_text: "あなたは店の隅に座る老漁師へ、事件の夜について尋ねた。",
    position: 1
  },
  {
    scene_key: "anchor_and_foghorn",
    next_scene_key: "keeper_house",
    text: "灯台守の家について店主に尋ねる",
    result_text: "店主から場所を聞き、町外れにある灯台守の家へ向かった。",
    position: 2
  },
  {
    scene_key: "anchor_and_foghorn",
    next_scene_key: "erased_arrival_record",
    text: "帳簿から消えた船の噂を確かめる",
    result_text: "酒場で聞いた噂を確かめるため、港の古い入港記録を調べることにした。",
    position: 3
  },
  {
    scene_key: "silent_fisherman",
    next_scene_key: "keeper_house",
    text: "事件当夜の話を最後まで聞く",
    result_text: "老漁師は証言を終えると、銀色の方位磁針をあなたに託した。",
    position: 1,
    add_flags: [ "fisherman_testimony" ],
    add_items: [ "silver_compass" ]
  },
  {
    scene_key: "silent_fisherman",
    next_scene_key: "shipwreck_beach",
    text: "方位磁針を借り、難破船を探す",
    result_text: "老漁師の証言と方位磁針を頼りに、難破船が眠る浜辺へ向かった。",
    position: 2,
    add_flags: [ "fisherman_testimony" ],
    add_items: [ "silver_compass" ]
  },
  {
    scene_key: "silent_fisherman",
    next_scene_key: "foghorn_night",
    text: "要点だけを聞き、夜の灯台へ急ぐ",
    result_text: "老漁師の証言だけを胸に、十分な道具を確認せず灯台へ急いだ。",
    position: 3,
    add_flags: [ "fisherman_testimony" ]
  },
  {
    scene_key: "silent_fisherman",
    next_scene_key: "bad_ending",
    text: "漁師の警告を無視し、一人で霧の海へ出る",
    result_text: "あなたは止める声を振り切り、小舟で濃霧の海へ進んだ。",
    position: 4
  },
  {
    scene_key: "erased_arrival_record",
    next_scene_key: "shipwreck_beach",
    text: "密輸船の印と帳簿の欠番を照合する",
    result_text: "木箱の印と帳簿を照合し、消された船が着いた浜辺を特定した。",
    position: 1,
    required_flags: [ "smuggling_ship_mark" ],
    add_flags: [ "erased_record" ]
  },
  {
    scene_key: "erased_arrival_record",
    next_scene_key: "shipwreck_beach",
    text: "管理人の警告を手掛かりに夜間記録を探す",
    result_text: "警告された時刻の記録から、意図的に消された入港記録を発見した。",
    position: 2,
    required_flags: [ "manager_warning" ],
    add_flags: [ "erased_record" ]
  },
  {
    scene_key: "erased_arrival_record",
    next_scene_key: "shipwreck_beach",
    text: "破られた控えをつなぎ合わせる",
    result_text: "破片をつなぎ、正体不明の船が着いた浜辺の位置を読み取った。",
    position: 3,
    add_flags: [ "erased_record" ]
  },
  {
    scene_key: "erased_arrival_record",
    next_scene_key: "keeper_house",
    text: "復元した記録を持って灯台守の家へ向かう",
    result_text: "消された入港記録を写し取り、灯台守が残した情報を探しに向かった。",
    position: 4,
    add_flags: [ "erased_record" ]
  },
  {
    scene_key: "shipwreck_beach",
    next_scene_key: "foghorn_night",
    text: "方位磁針を頼りに難破船を探す",
    result_text: "方位磁針が示す先で、秘密の航路が描かれた破れた海図を発見した。",
    position: 1,
    required_items: [ "silver_compass" ],
    add_items: [ "torn_chart" ]
  },
  {
    scene_key: "shipwreck_beach",
    next_scene_key: "foghorn_night",
    text: "密輸船の印がある残骸を調べる",
    result_text: "同じ印が付いた船室から、破れた海図を発見した。",
    position: 2,
    required_flags: [ "smuggling_ship_mark" ],
    add_items: [ "torn_chart" ]
  },
  {
    scene_key: "shipwreck_beach",
    next_scene_key: "foghorn_night",
    text: "消された記録にある座標を調べる",
    result_text: "記録の座標と一致する残骸から、秘密の航路が描かれた海図を見つけた。",
    position: 3,
    required_flags: [ "erased_record" ],
    add_items: [ "torn_chart" ]
  },
  {
    scene_key: "shipwreck_beach",
    next_scene_key: "bad_ending",
    text: "手掛かりを使わず、濃霧の奥へ強引に進む",
    result_text: "あなたは目印のない濃霧へ踏み込み、波音の中で帰り道を失った。",
    position: 4
  },
  {
    scene_key: "keeper_house",
    next_scene_key: "foghorn_night",
    text: "手紙を読み、真鍮の鍵と予備のランタンを持つ",
    result_text: "灯台守の手紙を読み、残されていた鍵とランタンを持って灯台へ向かった。",
    position: 1,
    add_flags: [ "lighthouse_keeper_letter" ],
    add_items: [ "brass_key", "old_lantern" ]
  },
  {
    scene_key: "keeper_house",
    next_scene_key: "foghorn_night",
    text: "漁師の証言を手掛かりに床下を探す",
    result_text: "証言にあった床板の下から、灯台守の手紙と真鍮の鍵を発見した。",
    position: 2,
    required_flags: [ "fisherman_testimony" ],
    add_flags: [ "lighthouse_keeper_letter" ],
    add_items: [ "brass_key" ]
  },
  {
    scene_key: "keeper_house",
    next_scene_key: "foghorn_night",
    text: "家に残されたものには触れず立ち去る",
    result_text: "あなたは何も持ち出さず、霧笛が鳴る灯台へ向かった。",
    position: 3
  },
  {
    scene_key: "foghorn_night",
    next_scene_key: "lighthouse_entrance",
    text: "古いランタンで足元を照らして進む",
    result_text: "ランタンの光を頼りに霧を抜け、灯台の正面へたどり着いた。",
    position: 1,
    required_items: [ "old_lantern" ]
  },
  {
    scene_key: "foghorn_night",
    next_scene_key: "lighthouse_entrance",
    text: "銀色の方位磁針が示す方角へ進む",
    result_text: "方位磁針は霧の中でも正確に灯台の方角を示した。",
    position: 2,
    required_items: [ "silver_compass" ]
  },
  {
    scene_key: "foghorn_night",
    next_scene_key: "lighthouse_road",
    text: "破れた海図に描かれた道を進む",
    result_text: "海図にだけ描かれた崖沿いの道を見つけ、灯台へ近づいた。",
    position: 3,
    required_items: [ "torn_chart" ]
  },
  {
    scene_key: "foghorn_night",
    next_scene_key: "bad_ending",
    text: "道具を使わず、霧笛の音だけを追う",
    result_text: "霧笛の音は何度も方向を変え、あなたを霧の奥へ誘い込んだ。",
    position: 4
  },
  {
    scene_key: "lighthouse_road",
    next_scene_key: "spiral_staircase",
    text: "管理人の警告を思い出し、干潮時の裏口へ進む",
    result_text: "警告に含まれていた潮の時刻を思い出し、灯台内部へ続く裏口を見つけた。",
    position: 1,
    required_flags: [ "manager_warning" ]
  },
  {
    scene_key: "lighthouse_road",
    next_scene_key: "lighthouse_entrance",
    text: "方位磁針を使って正面への道を選ぶ",
    result_text: "方位磁針で方向を確かめながら、灯台の正面へ向かった。",
    position: 2,
    required_items: [ "silver_compass" ]
  },
  {
    scene_key: "lighthouse_road",
    next_scene_key: "underground_passage",
    text: "海図にある潮だまりの地下道へ入る",
    result_text: "破れた海図を頼りに、灯台地下へ直接続く道を見つけた。",
    position: 3,
    required_items: [ "torn_chart" ]
  },
  {
    scene_key: "lighthouse_road",
    next_scene_key: "bad_ending",
    text: "目印のない崖道を強引に登る",
    result_text: "足元の岩が崩れ、霧の中で進む方向を完全に見失った。",
    position: 4
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "spiral_staircase",
    text: "真鍮の鍵を使って正面扉を開ける",
    result_text: "真鍮の鍵は鍵穴に合い、重い扉がゆっくりと開いた。",
    position: 1,
    required_items: [ "brass_key" ],
    remove_items: [ "brass_key" ]
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "underground_passage",
    text: "密輸船の印と同じ印がある搬入口を探す",
    result_text: "壁際で同じ印を見つけ、荷物を運ぶための地下搬入口を開いた。",
    position: 2,
    required_flags: [ "smuggling_ship_mark" ]
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "spiral_staircase",
    text: "管理人の警告にあった古い通用口を使う",
    result_text: "警告の内容を思い出し、壁陰に隠れた通用口から灯台へ入った。",
    position: 3,
    required_flags: [ "manager_warning" ]
  },
  {
    scene_key: "lighthouse_entrance",
    next_scene_key: "bad_ending",
    text: "大きな音を立てて正面扉を壊す",
    result_text: "扉を壊した音が灯台中に響き、霧の奥から何者かの足音が近づいた。",
    position: 4
  },
  {
    scene_key: "spiral_staircase",
    next_scene_key: "keeper_room",
    text: "古いランタンで階段と壁を照らす",
    result_text: "ランタンの光で安全な足場を確かめ、灯台守の部屋へたどり着いた。",
    position: 1,
    required_items: [ "old_lantern" ]
  },
  {
    scene_key: "spiral_staircase",
    next_scene_key: "clock_room",
    text: "灯台守の手紙に書かれた矢印をたどる",
    result_text: "手紙と壁の印を照合し、時計室へ続く隠し階段を見つけた。",
    position: 2,
    required_flags: [ "lighthouse_keeper_letter" ]
  },
  {
    scene_key: "spiral_staircase",
    next_scene_key: "clock_room",
    text: "破れた海図の灯台断面図を確認する",
    result_text: "海図の裏に描かれた断面図から、時計室の位置を特定した。",
    position: 3,
    required_items: [ "torn_chart" ]
  },
  {
    scene_key: "spiral_staircase",
    next_scene_key: "bad_ending",
    text: "暗闇の中を手探りで登る",
    result_text: "見えない段差を踏み外し、あなたの声は暗い灯台の中へ消えた。",
    position: 4
  },
  {
    scene_key: "keeper_room",
    next_scene_key: "clock_room",
    text: "灯台守の手紙と運用日誌を照合する",
    result_text: "二つの記述から、事件の時刻と時計室に隠された仕掛けが分かった。",
    position: 1,
    required_flags: [ "lighthouse_keeper_letter" ]
  },
  {
    scene_key: "keeper_room",
    next_scene_key: "underground_passage",
    text: "漁師の証言を手掛かりに壁の図を調べる",
    result_text: "証言にあった船の位置と壁の図が一致し、地下への隠し通路が開いた。",
    position: 2,
    required_flags: [ "fisherman_testimony" ]
  },
  {
    scene_key: "keeper_room",
    next_scene_key: "normal_ending",
    text: "運用日誌を証拠として町へ持ち帰る",
    result_text: "あなたは無理に先へ進まず、発、発見した日誌を町の人々へ届けた。",
    position: 3
  },
  {
    scene_key: "clock_room",
    next_scene_key: "underground_passage",
    text: "消された記録の時刻と時計を照合する",
    result_text: "二つの時刻が一致し、事件が起きた瞬間と地下への仕掛けを特定した。",
    position: 1,
    required_flags: [ "erased_record" ],
    add_flags: [ "stopped_clock_time" ]
  },
  {
    scene_key: "clock_room",
    next_scene_key: "underground_passage",
    text: "灯台守の手紙どおりに時計の針を動かす",
    result_text: "手紙に記された時刻へ針を合わせると、地下への階段が現れた。",
    position: 2,
    required_flags: [ "lighthouse_keeper_letter" ],
    add_flags: [ "stopped_clock_time" ]
  },
  {
    scene_key: "clock_room",
    next_scene_key: "normal_ending",
    text: "時計室で得た証拠を持って町へ戻る",
    result_text: "あなたは判明した時刻と日誌を証拠として持ち帰った。",
    position: 3
  },
  {
    scene_key: "clock_room",
    next_scene_key: "bad_ending",
    text: "手掛かりを無視して時計の機構を壊す",
    result_text: "壊れた機構が大きな音を立て、灯台全体が激しく揺れ始めた。",
    position: 4
  },
  {
    scene_key: "underground_passage",
    next_scene_key: "hidden_harbor",
    text: "破れた海図が示す地下航路を進む",
    result_text: "海図の線と通路を照合し、隠された港へ続く道を選んだ。",
    position: 1,
    required_items: [ "torn_chart" ]
  },
  {
    scene_key: "underground_passage",
    next_scene_key: "hidden_harbor",
    text: "密輸船の印が刻まれた通路を進む",
    result_text: "倉庫で見た印と同じ印を追い、密輸団が使う隠し港へ近づいた。",
    position: 2,
    required_flags: [ "smuggling_ship_mark" ]
  },
  {
    scene_key: "underground_passage",
    next_scene_key: "hidden_harbor",
    text: "漁師の証言と灯台守の手紙を照合する",
    result_text: "証言と手紙に共通する波音の方角を選び、正しい通路を進んだ。",
    position: 3,
    required_flags: [ "fisherman_testimony", "lighthouse_keeper_letter" ]
  },
  {
    scene_key: "underground_passage",
    next_scene_key: "bad_ending",
    text: "印のない通路へ勘だけで進む",
    result_text: "通路は深い霧の洞窟へ続き、戻るための目印も見失った。",
    position: 4
  },
  {
    scene_key: "hidden_harbor",
    next_scene_key: "confrontation",
    text: "消された記録と止まった時計の時刻を示す",
    result_text: "船の入港時刻と灯台の停止時刻が一致し、首謀者の逃走経路が判明した。",
    position: 1,
    required_flags: [ "erased_record", "stopped_clock_time" ]
  },
  {
    scene_key: "hidden_harbor",
    next_scene_key: "confrontation",
    text: "漁師の証言と灯台守の手紙を示す",
    result_text: "二人が残した情報から、首謀者が身を隠す船を特定した。",
    position: 2,
    required_flags: [ "fisherman_testimony", "lighthouse_keeper_letter" ]
  },
  {
    scene_key: "hidden_harbor",
    next_scene_key: "confrontation",
    text: "破れた海図と密輸船の印を照合する",
    result_text: "秘密の航路と船の印が一致し、密輸団の逃走船を突き止めた。",
    position: 3,
    required_flags: [ "smuggling_ship_mark" ],
    required_items: [ "torn_chart" ]
  },
  {
    scene_key: "hidden_harbor",
    next_scene_key: "normal_ending",
    text: "失踪者の救出を優先して町へ戻る",
    result_text: "あなたは首謀者の追跡よりも、捕らわれていた人々の救出を選んだ。",
    position: 4
  },
  {
    scene_key: "confrontation",
    next_scene_key: "true_ending",
    text: "消された記録と止まった時計で計画を証明する",
    result_text: "改ざんされた記録と事件時刻が、首謀者の計画を動かぬ証拠にした。",
    position: 1,
    required_flags: [ "erased_record", "stopped_clock_time" ]
  },
  {
    scene_key: "confrontation",
    next_scene_key: "true_ending",
    text: "海図と密輸船の印で秘密の航路を暴く",
    result_text: "破れた海図と船の印によって、密輸航路の全体像が明らかになった。",
    position: 2,
    required_flags: [ "smuggling_ship_mark" ],
    required_items: [ "torn_chart" ]
  },
  {
    scene_key: "confrontation",
    next_scene_key: "true_ending",
    text: "漁師の証言、灯台守の手紙、方位磁針を示す",
    result_text: "証言と手紙を方位磁針が示した航路に重ね、灯台守が守ろうとした真実を証明した。",
    position: 3,
    required_flags: [ "fisherman_testimony", "lighthouse_keeper_letter" ],
    required_items: [ "silver_compass" ]
  },
  {
    scene_key: "confrontation",
    next_scene_key: "normal_ending",
    text: "現在ある証拠だけで事件を告発する",
    result_text: "事件は止められたが、証拠が足りず密輸の全容までは明らかにできなかった。",
    position: 4
  }
]

flag_rule_types = {
  required_flags: :required,
  add_flags: :add,
  remove_flags: :remove
}

item_rule_types = {
  required_items: :required,
  add_items: :add,
  remove_items: :remove
}

sample_choices.each do |attributes|
  scene = scenes_by_key.fetch(attributes[:scene_key])
  next_scene = scenes_by_key.fetch(attributes[:next_scene_key])

  choice = scene.choices.create!(
    next_scene: next_scene,
    text: attributes[:text],
    result_text: attributes[:result_text],
    position: attributes[:position]
  )

  flag_rule_types.each do |key, rule_type|
    Array(attributes[key]).each do |flag_key|
      choice.choice_flag_rules.create!(
        flag: flags_by_key.fetch(flag_key),
        rule_type: rule_type
      )
    end
  end

  item_rule_types.each do |key, rule_type|
    Array(attributes[key]).each do |item_key|
      choice.choice_item_rules.create!(
        item: items_by_key.fetch(item_key),
        rule_type: rule_type
      )
    end
  end
end

puts "選択肢を登録しました。"
puts "選択肢のフラグルールを登録しました。"
puts "選択肢の所持品ルールを登録しました。"
puts "シーン数: #{sample_gamebook.scenes.count}"
puts "選択肢数: #{sample_gamebook.scenes.sum { |scene| scene.choices.count }}"
puts "フラグ数: #{sample_gamebook.flags.count}"
puts "所持品数: #{sample_gamebook.items.count}"
