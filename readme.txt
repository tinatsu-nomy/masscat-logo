　回転するロゴ ～ますきゃ勝手ロゴ～
　　　Post_ScreenTex.fx改変　by 乃美ちなつ

　MME
　・MassCat_W.x - バックが非透過
　・MassCat_B.x - バックが透過
　・MassCat_T.x - 回転するテキスト

　使い方
　　アクセサリー表示順の最後の方に
　　　(1)MassCat_W.xまたは、MassCat_B.x
　　　(2)MassCat_T.x
　　との順((1)→(2)で描写)で、配置してください。
　　(2)は再生を始めると回転を始めます。デフォルト10秒に1回転。
　　MassCat_T.fxで回転速度を変える事ができます。

　パラメタ説明。※パラメタの位置を改変元から変えています。
　　X,Y: 位置 -100～100 (左端,下が-100, 右端,上が100)
　　Z:   カラーキーの閾値 (Post_ScreenTex.fxのRx)
　　Rx,Ry,Rz: カラーキーの色(RGB指定)  (Post_ScreenTex.fxのX,Y,Z)
　　Si:  拡大率
　　Tr:  透過率

　　16:9の場合の右上の例: X:93 Y:88 Si:0.75 Tr:1.0

　最後に、規約などは、改変元の針金P様のPost_ScreenTex.fxに準じます。


