*PipeWork*
============

*PipeWork* Component
--------------------

####REDUCER####

異なるデータ幅のパスを継ぐためのアダプタです.  
詳細は [docs/ja/reducer.md](docs/ja/reducer.md) を参照.

####CHOPPER####

先頭アドレスとサイズで示されたブロックを、指定された大きさのピースに分割する回路です.  
詳細は [docs/ja/chopper.md](docs/ja/chopper.md) を参照.

####QUEUE ARBITER####

キュー(ファーストインファーストアウト)方式の調停回路です.  
詳細は [docs/ja/queue_arbiter.md](docs/ja/queue_arbiter.md) を参照.

####SYNCRONIZER####

異なるクロックで動作するパスを継ぐアダプタのクロック同期化回路です.  
詳細は [docs/ja/syncronizer.md](docs/ja/syncronizer.md) を参照.

####QUEUE REGISTER####

フリップフロップベースの比較的浅いキュー.

####DELAY REGISTER####

入力データを指定したクロックだけ遅延して出力する回路です.  
遅延するクロック数はジェネリック変数および信号によって設定することが出来ます.

####DELAY ADJUSTER####

入力データを DELAY REGISTER の出力に合わせて調整して出力する回路です.

*PipeWork* AIX4 Component
-------------------------

####AXI4_TYPES####

AXI4 I/F の信号のタイプなどを定義しているパッケージです.

####AXI4_MASTER_READ_CONTROLLER####

AXI4 Master Read コントローラーです.

####AXI4_MASTER_WRITE_CONTROLLER####

AXI4 Master Write コントローラーです.

####AXI4_REGISTER_INTERFACE####

AXI4 スレーブ I/F から簡単なレジスタアクセスを行うためのアダプタです.


*PipeWork* Examples
-------------------

*PipeWork* Componentを使った例です.

####FIFO with done####

終了処理付きのFIFOです.  
詳細は [docs/ja/fifo_with_done.md](docs/ja/fifo_with_done.md) を参照.

####PUMP AXI4 to AXI4####

入力側と出力側に AXI4 Master I/F を持つポンプ(所謂DMA)です.

ライセンス
----------

二条項BSDライセンス (2-clause BSD license) で公開しています。
