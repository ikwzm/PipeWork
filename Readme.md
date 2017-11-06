*PipeWork*
============

*PipeWork* Component
--------------------

#### REDUCER

異なるデータ幅のパスを継ぐためのアダプタです.  
詳細は [docs/ja/reducer.md](docs/ja/reducer.md) を参照.

#### CHOPPER

先頭アドレスとサイズで示されたブロックを、指定された大きさのピースに分割する回路です.  
詳細は [docs/ja/chopper.md](docs/ja/chopper.md) を参照.

#### QUEUE ARBITER

キュー(ファーストインファーストアウト)方式の調停回路です.  
詳細は [docs/ja/queue_arbiter.md](docs/ja/queue_arbiter.md) を参照.

#### SYNCRONIZER

異なるクロックで動作するパスを継ぐアダプタのクロック同期化回路です.  
詳細は [docs/ja/syncronizer.md](docs/ja/syncronizer.md) を参照.

#### QUEUE REGISTER

フリップフロップベースの比較的浅いキュー.     
出力側の出力信号をレジスタで叩いてから出力している.

#### QUEUE RECEIVER

フリップフロップベースの比較的浅いキュー.    
入力側の入力信号をレジスタで一度受けている.

#### DELAY REGISTER

入力データを指定したクロックだけ遅延して出力する回路です.  
遅延するクロック数はジェネリック変数および信号によって設定することが出来ます.

#### DELAY ADJUSTER

入力データを DELAY REGISTER の出力に合わせて調整して出力する回路です.

#### PRIORITY_ENCODER_PROCEDURES

汎用のプライオリティエンコーダーを生成するためのプロシージャ/関数を定義しているパッケージ.

*PipeWork* PUMP Component
-------------------------

#### PUMP_CONTROLLER

データを入力(INTAKE)側から入力し、出力(OUTLET)側に出力するためのコントローラです.    

#### PUMP_OPERATION_PROCESSOR

PUMP_CONTROLLERの動作を、メモリ上に展開したオペレーションリストに基づいて行うプロセッサもどきです.   


*PipeWork* PIPE Component
-------------------------

#### PIPE_CORE_UNIT

バスプロトコル変換用のコアユニットです.

*PipeWork* AIX4 Component
-------------------------

#### AXI4_TYPES

AXI4 I/F の信号のタイプなどを定義しているパッケージです.    

#### AXI4_MASTER_READ_INTERFACE

AXI4 Master Read コントローラーです.    

#### AXI4_MASTER_WRITE_INTERFACE

AXI4 Master Write コントローラーです.    

#### AXI4_SLAVE_READ_INTERFACE

AXI4 Slave Read コントローラーです.    

#### AXI4_SLAVE_WRITE_INTERFACE

AXI4 Slave Write コントローラーです.    

#### AXI4_REGISTER_INTERFACE

AXI4 スレーブ I/F から簡単なレジスタアクセスを行うためのアダプタです.    


*PipeWork* Examples
-------------------

*PipeWork* Componentを使った例です.

#### FIFO with done

終了処理付きのFIFOです.  
詳細は [https://github.com/ikwzm/FIFO_with_done](https://github.com/ikwzm/FIFO_with_done) を参照.

#### PUMP AXI4 to AXI4

入力側と出力側に AXI4 Master I/F を持つポンプ(所謂DMA)です.
詳細は [https://github.com/ikwzm/PUMP_AXI4](https://github.com/ikwzm/PUMP_AXI4) を参照.

ライセンス
----------

二条項BSDライセンス (2-clause BSD license) で公開しています。
