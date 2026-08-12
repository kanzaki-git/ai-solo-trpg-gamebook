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
    body: "相次ぐ失踪事件の真相を確かめるため、あなたは霧深い港町を訪れた。\n\n船を降りると、潮の匂いを含んだ冷たい霧が波止場を覆っていた。沖には古い灯台の光がかすかに揺れ、町のどこかから腹の底へ響くような霧笛が聞こえてくる。\n\n波止場の正面には港湾管理事務所があり、少し離れた場所には使われなくなった倉庫が並んでいる。坂の上では、酒場「錨と霧笛」の看板が霧の中で揺れていた。\n\n事件の記録を調べるか、波止場に残された痕跡を追うか、それとも町の住民から話を聞くか。あなたは最初の調査先を選ぶことにした。",
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
    body: "事件の記録を調べるため、あなたは港湾管理事務所を訪れた。\n\n港湾管理人は失踪事件について尋ねると表情を曇らせ、夜の灯台には近づかないよう強く警告した。霧笛が三度鳴る頃には灯台下の潮が引くが、崖側にある古い通用口には決して近づいてはならないという。\n\n管理人の背後には、船の入港記録と荷物の運搬記録が収められた書棚がある。事件当夜の帳簿だけ一部が破られており、残された伝票には波止場の古い倉庫を示す番号が記されていた。\n\n管理人の警告を詳しく聞きながら帳簿を調べるか、荷物の行き先を追うか、住民の証言を集めるか。次の調査先につながる手掛かりが、ここには残されている。",
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
    body: "波止場に残された痕跡を調べるため、あなたは使われなくなった古い倉庫へ入った。\n\n湿った倉庫の奥には、同じ印が焼き付けられた木箱がいくつも積まれている。箱には港の帳簿と照合できそうな管理番号が残されており、正規の荷物ではないことを示すように送り主の名前だけが削られていた。\n\n壁際には、わずかに燃料の残った古いランタンが掛けられている。床には最近ついたと思われる荷車の跡があり、壊れた裏口から霧に覆われた浜辺へ続いていた。\n\n木箱の情報を港の記録と照合するか、酒場で印について聞き込むか、それとも荷車の跡を追うか。倉庫で見つけた痕跡は、それぞれ別の調査先へつながっている。",
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
    body: "失踪事件の噂を集めるため、あなたは酒場「錨と霧笛」を訪れた。\n\n店内では、灯台の明かりが消えた夜から人が行方不明になっているという話が、小声で交わされている。店主によれば、港の帳簿から一隻の船の記録が消され、その直後に灯台守も姿を消したらしい。\n\n町外れにある灯台守の家は、失踪した夜から無人のままだという。店の隅には、その夜に海へ出ていた老漁師が座っているが、周囲の客を警戒するように黙り込んでいた。\n\n事件当夜を知る老漁師に話を聞くか、灯台守の家を調べるか、消された船の記録を探すか。酒場で得た噂から、次の調査先を選ぶことができる。",
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
    body: "あなたが事件の夜について尋ねると、老漁師は周囲を確かめてから、重い口を開いた。\n\nあの夜、印の付いた見慣れない船が灯台の下へ近づき、崖の陰へ消えていったという。その直後に灯台の光が消え、海から助けを求める声が聞こえた。\n\n灯台守は失踪する前、老漁師に『私に何かあったら、家の床下を調べてほしい』と伝えていた。さらに老漁師は、濃霧の中で難破船や灯台を探すなら、方位を見失わないための道具が必要だと警告する。\n\n灯台守の家へ向かうか、老漁師から方位磁針を借りて浜辺を調べるか、それとも警告を無視して灯台や霧の海へ急ぐか。ここでの判断が、霧の中から戻れるかどうかを左右する。",
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
    body: "事件当夜の記録を確かめるため、あなたは破られた帳簿と控えを机の上に広げた。\n\n事件が始まった夜の記録だけ、複数のページが意図的に抜き取られている。残された断片には、正体不明の船、積み荷に付けられた奇妙な印、そして途中まで消された荷下ろし場所の座標が記されていた。\n\n記録の確認者欄には、行方不明になった灯台守の署名が残っている。その横には『この船を灯台へ近づけてはならない』という走り書きがあった。灯台守は失踪する前に、何らかの危険へ気づいていたらしい。\n\nこれまでに見つけた印や管理人の警告と記録を照合するか、破られた控えをつなぎ合わせるか、それとも灯台守の家で署名の理由を調べるか。調査方法を選べば、消された記録の先を追うことができる。",
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
    body: "これまでに得た手掛かりを追い、あなたは町外れの浜辺へたどり着いた。\n\n海岸は濃い霧に覆われ、波打ち際には古い船の残骸が広い範囲に散らばっている。砂に半分埋もれた木片の一部には、由来の分からない奇妙な印が刻まれていた。\n\n沖に近い場所には、船室の一部と思われる大きな残骸が横たわっている。しかし霧と波によって周囲の景色が何度も変わり、目印を持たずに近づけば帰り道を失いかねない。\n\nこれまでに手に入れた道具や情報を正しく使えば、残骸の中から秘密の航路が描かれた海図を探し出せそうだ。手掛かりを使うか、危険を承知で濃霧へ踏み込むか。あなたは難破船の調べ方を決めることにした。",
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
    body: "町で得た手掛かりを頼りに、あなたは町外れにある灯台守の家を訪れた。\n\n玄関の扉に鍵は掛かっておらず、室内には灯台守が突然姿を消した夜のまま、食器や作業着が残されている。机の上には、密輸船と灯台地下の異変について書かれた手紙が置かれていた。\n\n手紙の末尾には、灯台内部で目印となる矢印と、時計の針が示す時刻が記されている。さらに『私に何かあれば、机の下の床板を調べてほしい』という一文があった。\n\n机の下には一枚だけ浮いた床板があり、棚には燃料の残った予備のランタンが置かれている。手紙を読みながら家を詳しく調べるか、これまでに聞いた証言を頼りに床下を探すか、それとも何も持ち出さず灯台へ向かうか。あなたは次の行動を決めることにした。",
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
    body: "灯台へ向かう頃には日が沈み、港町と海を覆う霧は昼間よりも濃くなっていた。\n\n灯台へ続く道には街灯がなく、足元の石畳さえ数歩先で見えなくなる。闇の奥から霧笛が響くたびに音が崖や海面で反射し、灯台の方角が変わったように感じられた。\n\n道の分岐には、かすれた案内標識と古い石の目印が残っている。明かりがあれば足元の印を追うことができ、方位を示す道具があれば霧に惑わされず進めるだろう。秘密の航路を記した海図には、町の道にはない崖沿いの経路も描かれている。\n\n手元の道具を使って安全な経路を探すか、霧笛の音だけを頼りに進むか。夜の霧を越える方法を選ばなければならない。",
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
    body: "破れた海図に描かれた細い道をたどり、あなたは灯台を見上げる崖沿いの分岐へたどり着いた。\n\n上へ続く石段は灯台の正面へ向かっている。一方、海側へ下る道は普段なら海中に沈んでいるが、霧笛が三度鳴った今は潮が引き、岩壁の奥に古い通用口と地下道が姿を現していた。\n\n海図の裏面には灯台内部の簡単な断面図も描かれている。正面扉へ続く道だけでなく、崖側の通用口や灯台地下へ直接入れる潮だまりの通路も記されていた。\n\n管理人の警告、方位磁針、破れた海図。これまでに得た情報や道具を使えば、安全な進入経路を選べるだろう。手掛かりを使わず、目印のない崖道を登ることもできるが、足元の岩は波と霧で滑りやすくなっている。",
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
    body: "霧を抜けたあなたは、波しぶきを受けてそびえる灯台の正面へたどり着いた。\n\n分厚い正面扉は固く閉ざされ、中央には潮風で錆びた鍵穴がある。扉の周囲には何度も荷物を運び込んだような傷が残り、壁際の石には倉庫や船の残骸で見たものと似た印が刻まれていた。\n\n灯台の側面には、正面からは見えにくい古い通用口もある。扉を開ける鍵、荷物の搬入口を示す印、通用口についての情報。手元に対応する手掛かりがあれば、灯台内部へ入れるはずだ。\n\n手掛かりを使って静かに侵入するか、大きな音を立てて正面扉を壊すか。灯台へ入る方法を選ばなければならない。",
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
    body: "灯台の内部へ入ると、冷たく湿った空気の中に、上階へ続く螺旋階段が浮かび上がった。\n\n窓は板で塞がれ、階段の先は完全な暗闇に包まれている。足元には崩れた段差があり、手探りで進めば転落する危険がある。\n\n壁には灯台守が残したと思われる矢印と、時計を表す小さな印が刻まれている。灯台守の手紙や海図の裏面に描かれた断面図があれば、この印が示す行き先を判断できそうだ。\n\n明かりで足場を確かめながら灯台守の部屋を目指すか、残された情報を使って時計室への隠し階段を探すか。それとも暗闇を手探りで進むか。慎重に経路を選ぶ必要がある。",
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
    body: "ランタンで足元を照らしながら階段を進み、あなたは灯台守が使っていた部屋へたどり着いた。\n\n机の上には灯台の運用日誌が開かれたまま残されている。最後のページには、正体不明の船が夜ごと灯台へ近づき、地下へ荷物を運び込んでいたことが記されていた。\n\n壁には灯台と崖下を結ぶ地下通路の図が貼られている。図の端には事件当夜の船の位置と、時計室へ続く仕掛けが書き込まれていた。\n\n灯台守の手紙や老漁師の証言と照合すれば、真相へ続く経路を特定できるだろう。ここまでに得た日誌を証拠として町へ持ち帰り、調査を終えることもできる。",
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
    body: "隠された階段を上ると、巨大な歯車に囲まれた時計室へ出た。\n\n塔の時計は、失踪事件が起きた夜のある時刻を指したまま止まっている。機械全体は厚いほこりに覆われているが、針を動かす部分だけには、最近誰かが触れたような傷が残っていた。\n\n時計の台座には複数の時刻が刻まれた金属板があり、その背後から地下へ続く空洞の音が聞こえる。消された入港記録や灯台守の手紙と照合し、正しい時刻へ針を合わせれば、隠された仕掛けを動かせそうだ。\n\n証拠を使って地下への道を開くか、時計室で見つけた情報を町へ持ち帰るか。それとも手掛かりを無視して機構を動かすか。次の判断が事件の核心へ進めるかを決める。",
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
    body: "灯台の仕掛けや隠された入口を通り、あなたは湿った石造りの地下通路へ降りた。\n\n通路は途中で三方向に分かれている。左の壁には潮の流れを表すような線、中央の通路には積み荷に使われていた奇妙な印、右の壁には灯台守が残したものと似た矢印が刻まれていた。\n\n遠くから波の音と、複数の人間が話す声が聞こえる。しかし音は狭い通路の中で反響し、どの方向から響いているのか判断しにくい。\n\n海図、密輸船の印、灯台守の手紙。手元にある手掛かりと壁の目印を照合すれば、隠された港へ続く正しい道を選べるだろう。何も確認せず、印のない通路へ進むこともできるが、戻るための目印はない。",
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
    body: "手掛かりが示す通路を進むと、岩壁の奥に造られた小さな港へたどり着いた。\n\n外からは見えない入り江に、印の付いた木箱と数隻の小舟が並んでいる。失踪した町の人々はここへ連れ去られ、密輸品の積み下ろしを強いられていた。\n\nあなたの姿に気づいた密輸団の首謀者は、証拠となる帳簿を抱えて沖の船へ逃げようとしている。一方、捕らわれた人々は鎖につながれ、このままでは満ち始めた潮に取り残されてしまう。\n\n集めた記録、証言、手紙、海図を組み合わせれば、首謀者が乗り込もうとしている逃走船を特定できる。首謀者を追って事件の全容を暴くか、失踪者の救出を優先するか。ここでの決断が事件の結末を分ける。",
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
    body: "集めた証拠から逃走船を特定し、あなたは出航直前の船へ乗り込んだ。\n\n甲板では密輸団の首謀者が、港と灯台を結ぶ取引帳簿を燃やそうとしている。首謀者は失踪事件への関与を否定し、残された証拠だけでは自分を止められないと言い放った。\n\nしかし、消された入港記録と時計の停止時刻、秘密の航路を示す海図と密輸船の印、老漁師の証言と灯台守の手紙。それぞれを正しく組み合わせれば、密輸計画と失踪事件を結びつけることができる。\n\n集めた証拠で事件の全容を証明するか、現在判明している事実だけで密輸団を告発するか。あなたは最後の証拠を首謀者へ突きつける。",
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
    body: "警告を退け、手掛かりを確かめないまま進んだ一度の判断が、あなたの帰り道を閉ざした。\n\n海、崖、灯台、そして地下通路。霧に覆われた場所では、小さな判断の誤りが取り返しのつかない結果を招く。助けを求める声は霧笛と波音にかき消され、やがて港町へ届かなくなった。\n\n翌朝、町の人々が見つけたのは、調査の途中で残されたわずかな痕跡だけだった。失踪事件の真相は再び霧の中へ隠され、古い灯台では何事もなかったかのように霧笛が鳴り続けている。",
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
    body: "あなたが持ち帰った記録や日誌、あるいは救出した人々の証言によって、港町で行われていた密輸と失踪事件の関係が明らかになった。\n\n町の人々は協力して灯台と地下通路を捜索し、残されていた失踪者たちを救い出した。密輸に使われていた入り江も閉鎖され、夜ごと聞こえていた不審な船の音は止んだ。\n\nしかし密輸団の首謀者は、証拠の一部を持ったまま霧の海へ逃げている。灯台守が最後に何を見つけ、どこへ連れ去られたのかも分からないままだ。\n\n事件は終わった。それでも古い灯台には、まだ解かれていない謎が残されている。",
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
    body: "あなたが示した証拠によって、消された入港記録、灯台の停止時刻、秘密の航路、そして町で続いていた失踪事件が一つにつながった。\n\n言い逃れができなくなった首謀者は取り押さえられ、燃やされかけた取引帳簿も回収された。船の奥に閉じ込められていた灯台守と失踪者たちは救出され、密輸団の協力者も記録から明らかになった。\n\n灯台守は、町の人々を守るために密輸の証拠を集めていたこと、発覚を恐れた密輸団によって連れ去られたことを語った。彼が残した手掛かりは、あなたの調査によって真実へたどり着いた。\n\n夜が明けると、朝日が港を覆っていた霧をゆっくりと払い始めた。古い灯台には再び正しい光がともり、港町は本当の静けさを取り戻した。",
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
    text: "管理人の警告を書き留め、事件当夜の帳簿を調べる",
    result_text: "霧笛と潮の時刻、古い通用口についての警告を書き留め、破られた入港記録を調べ始めた。",
    position: 1,
    add_flags: [ "manager_warning" ]
  },
  {
    scene_key: "harbor_office",
    next_scene_key: "old_warehouse",
    text: "管理人の警告を聞き、伝票が示す古い倉庫へ向かう",
    result_text: "潮が引く時刻と通用口への警告を書き留め、伝票の番号が示す古い倉庫へ向かった。",
    position: 2,
    add_flags: [ "manager_warning" ]
  },
  {
    scene_key: "harbor_office",
    next_scene_key: "anchor_and_foghorn",
    text: "管理人の警告を聞いたあと、酒場で住民の証言を集める",
    result_text: "灯台へ近づく危険と潮の時刻を覚え、事件当夜を知る住民を探して酒場へ向かった。",
    position: 3,
    add_flags: [ "manager_warning" ]
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "erased_arrival_record",
    text: "木箱の印と管理番号を写し、港の帳簿と照合する",
    result_text: "木箱の印と管理番号を写し取り、古いランタンを手に、対応する船を調べるため港の入港記録へ向かった。",
    position: 1,
    add_flags: [ "smuggling_ship_mark" ],
    add_items: [ "old_lantern" ]
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "anchor_and_foghorn",
    text: "古いランタンを持ち、木箱の印について酒場で聞き込む",
    result_text: "木箱の印を記録し、壁に残されていた古いランタンを持って、印を知る人物を探しに酒場へ向かった。",
    position: 2,
    add_flags: [ "smuggling_ship_mark" ],
    add_items: [ "old_lantern" ]
  },
  {
    scene_key: "old_warehouse",
    next_scene_key: "shipwreck_beach",
    text: "木箱の印を写し、荷車の跡を浜辺まで追う",
    result_text: "木箱の印を記録したあなたは、壊れた裏口から外へ出て、霧の中に残る荷車の跡を浜辺まで追った。",
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
    text: "証言を最後まで聞き、灯台守の家を調べる",
    result_text: "老漁師は事件当夜の証言を終えると、銀色の方位磁針をあなたに託した。あなたは灯台守が残した言葉を確かめるため、町外れの家へ向かった。",
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
    text: "管理人が話した霧笛と潮の時刻を、帳簿の断片と照合する",
    result_text: "霧笛が三度鳴る時刻と潮の記録を照合すると、消された船が荷物を下ろした浜辺の座標が判明した。",
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
    text: "机の手紙を読み、指示された床下と棚を調べる",
    result_text: "灯台守の手紙を読み、浮いた床板の下から真鍮の鍵を発見した。棚の予備ランタンも持ち、手紙に残された情報を頼りに灯台へ向かった。",
    position: 1,
    add_flags: [ "lighthouse_keeper_letter" ],
    add_items: [ "brass_key", "old_lantern" ]
  },
  {
    scene_key: "keeper_house",
    next_scene_key: "foghorn_night",
    text: "老漁師の証言を信じ、机の下の床板を調べる",
    result_text: "老漁師の言葉どおり床板を外すと、灯台守の手紙と真鍮の鍵が隠されていた。棚に残された予備ランタンも持ち、夜の灯台へ向かった。",
    position: 2,
    required_flags: [ "fisherman_testimony" ],
    add_flags: [ "lighthouse_keeper_letter" ],
    add_items: [ "brass_key", "old_lantern" ]
  },
  {
    scene_key: "keeper_house",
    next_scene_key: "foghorn_night",
    text: "家に残されたものには触れず、夜の灯台へ向かう",
    result_text: "あなたは手紙も道具も持ち出さず、家を出た。日が沈み、霧笛が響き始めた灯台へ向かった。",
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
    result_text: "真鍮の鍵を回すと、重い正面扉がゆっくりと開いた。同時に錆びた鍵は鍵穴の中で折れ、そのまま使えなくなった。",
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
    result_text: "あなたは無理に先へ進まず、発見した運用日誌を事件の証拠として町の人々へ届けた。",
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
    result_text: "あなたは時計の停止時刻と、時計室に残された記録を書き写し、事件の証拠として町へ持ち帰った。",
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
    text: "灯台守の手紙に描かれた矢印を壁の印と照合する",
    result_text: "手紙に残された矢印と壁の印が一致した。あなたは灯台守が示した通路を進み、波音と人の声が聞こえる隠し港へ近づいた。",
    position: 3,
    required_flags: [ "lighthouse_keeper_letter" ]
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
