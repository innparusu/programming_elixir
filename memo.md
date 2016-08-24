# 第5章 無名関数
- 無名関数は fn キーワードを使う

``` elixir
fn
  parameter-list -> body
  parameter-list -> body ...
end
```

- 無名関数は呼び出すときに ``.`` が必要
    - 名前付きはそれがない

## 5.1 関数とパターンマッチ
- elixir には「代入」というものはない
    - 代わりに値をパターンにマッチさせる(p13)
- ``a = 2`` は aを値2に束縛する事でパターンマッチを行う
    - tips 変数を束縛せずに現在の値をパターンしたいときは ``^a = 2`` のようにする

- 練習問題 Functions - 1

``` elixir
iex(1)> list_concat = fn a,b -> a++b end
iex(2)> list_concat.([:a, :b], [:c, :d])
[:a, :b, :c, :d]
iex(1)> sum = fn a,b,c -> a + b + c end
#Function<18.52032458/3 in :erl_eval.expr/5>
iex(2)> sum.(1,2,3)
6
iex(1)> pair_tuple_to_list = fn {a ,b} -> [a,b] end
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(2)> pair_tuple_to_list.({1234, 5678})
[1234, 5678]
```

## 5.2 一つの関数、 複数のボディ
- 一つの関数を定義するときに、渡された引数の型と内容によって異なる実装を定義できる
- ``handle_open``は``File.open`` が返すtupleによって挙動が異なる関数である
    - ``:file.format_error`` は errorを分かりやすい文字列にフォーマットするもの
    - ``:file`` は Elixir の土台の Erlang の File モジュールを参照する そのため, ``format_error``(これはErlangの関数?) を呼ぶことが出来る
- ``File`` は Elixir の組込みモジュールを参照する
- Elixir は 既存のErlang のライブラリ全てにアクセス出来る

``` elixir
iex(15)> handle_open = fn
...(15)>  {:ok, file} -> "Read data: #{IO.read(file, :line)}"
...(15)>  {_, error} -> "Error: #{:file.format_error(error)}"
...(15)> end
iex(20)> handle_open.(File.open("memo.md"))
```

## 5.3  関数は関数を返すことが出来る
- 下記の外部の関数には name というパラメータがある. 
    - あらゆるパラメータと同じく ``name`` は関数のボディの中ならどこででも利用できる
    - この場合, 内側の関数の文字列の中で name 変数を使っている
- 外側からみてスコープが外れている``name``が使える理由として, 関数が定義されたスコープにある変数の束縛を自分自身と一緒に持ちまわるから(クロージャ)
    - さっきの例では変数``name`` は外側の関数のスコープで束縛され、 内側の関数が定義された時, 内側の関数はこのスコープを受け継いで, ``name`` の束縛が持ち込まれる

``` elixir
iex(1)> greeter = fn name -> (fn -> "Hello #{name}" end) end
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(2)> dave_greeter = greeter.("Dave")
#Function<20.52032458/0 in :erl_eval.expr/5>
iex(3)> dave_greeter.()
"Hello Dave"
```

- つぎは外部と内部どちらも引数を取る例を考える

``` elixir
iex(4)> add_n = fn n -> (fn other -> n + other end) end
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(5)> add_two = add_n.(2)
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(7)> add_two.(3)
5
iex(8)> add_five = add_n.(5)
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(9)> add_five.(7)
12
```

## 5.4 関数を引数として渡す
- 関数はただの値なので、 他の関数に渡せる

``` elixir
iex(1)> times_2 = fn n -> n * 2 end
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(2)> apply = fn (fun, value) -> fun.(value) end
#Function<12.52032458/2 in :erl_eval.expr/5>
iex(3)> apply.(times_2, 6)
12
```

- Enum モジュールのmap はコレクションと関数の２つを引数に取り, コレクションの各要素に関数を適用した結果のリストを返す

``` elixir
iex(5)> list = [1,3,5,7,9]
[1, 3, 5, 7, 9]
iex(6)> Enum.map list, fn elem -> elem * 2 end
[2, 6, 10, 14, 18]
iex(7)> Enum.map list, fn elem -> elem * elem end
[1, 9, 25, 49, 81]
iex(8)> Enum.map list, fn elem -> elem > 6 end
[false, false, false, true, true]
```

### ピンで固定された値と関数パラメータ
- ピン演算子(^) は関数のパラメータでも使うことが出来る
- この例では２つのヘッド(パラメータのリスト)のある関数を返す.
    - 最初のヘッドは最初のパラメータと``for`` に渡された ``name`` が同じ時にマッチする

``` elixir
defmodule Greeter do
  
  def for(name, greeting) do
    fn
      (^name) -> "#{greeting} #{name}"
      (_) -> "I don't know you"
    end
  end

end

mr_valim = Greeter.for("Jose", "Oi!")

IO.puts mr_valim.("Jose")
IO.puts mr_valim.("dave")
```

### & 記法
- 短いヘルパー関数を作るという方法として Elixir はショートカットを提供している
- ``& 演算子``はそれ以降の式を関数に変換する
    - この指揮のなかで `&1, &2` といったプレースホルダーが最初の引数, 2番目の引数と対応している
    - つまり``&(&1 + &2)`` は `` fn p1, p2 -> p1 + p2 end`` に変換される
- Elixir はさらに賢く振る舞う
    - 例の``speak`` の ``&(IO.puts(&1))`` は ``fn x -> IO.puts(x) end`` となる. しかし, Elixir 箱の無名関数のボディが単なる名前付き関数(IO の puts) の呼び出しであることに気づく(しかも順序も同じ)
    - そこで Elixir は``IO.puts/1`` を直接参照するようにして無名関数を取り除いて最適化する
    - この働きをしてもらうには引数はそのままの順序である必要がある

``` elixir
iex(1)> add_one = &(&1 + 1)
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(2)> add_one.(44)
45
iex(3)> square = &(&1*&1)
#Function<6.52032458/1 in :erl_eval.expr/5>
iex(4)> square.(8)
64
iex(5)> speak = &(IO.puts(&1))
&IO.puts/1
iex(6)> speak.("Hello")
Hello
:ok
```

- このように関数を定義した時 Erlang の関数への参照が表示できたのが確認できる
- ``&abs(&1)`` のように書くと, Elixir abs関数の利用をは Erlang ライブラリに直接対応させ, ``&:erlang.abs/1`` を返す

``` elixir
iex(10)> rnd = &(Float.round(&1, &2))
&Float.round/2
iex(11)> rnd = &(Float.round(&2, &1))
#Function<12.52032458/2 in :erl_eval.expr/5>
```

- ``[]``  や ``{}`` は演算子なので, リストやタプルのリテラルは関数に変換することもできる

``` elixir
iex(13)> divrem = &{ div(&1, &2), rem(&1, &2) }
#Function<12.52032458/2 in :erl_eval.expr/5>
iex(14)> divrem.(13, 5)
{2, 3}
```

- & 関数補足演算子には二つ目の書き方がある
- 既に存在する関数の名前とアリティ(arity, パラメータの数) を渡すと, それを呼び出す無名関数を返す
    - ``&(IO.puts(&1))``と入力した時, ``&IO.puts/1`` が返ってくる この返ってくる値がそれ

``` elixir
iex(17)> l = &length/1
&:erlang.length/1
iex(18)> l.([1,2,3,4])
4
iex(19)> len = &Enum.count/1
&Enum.count/1
iex(20)> len.([1,2,3,4])
4
iex(21)> m = &Kernel.min/2
&:erlang.min/2
iex(22)> m.(99,88)
88
```

- & ショートカットは関数を他の関数に渡すための見事な方法

``` elixir
iex(23)> Enum.map [1,2,3,4], &(&1 + 1)
[2, 3, 4, 5]
iex(24)> Enum.map [1,2,3,4], &(&1 * &1)
[1, 4, 9, 16]
iex(25)> Enum.map [1,2,3,4], &(&1 < 3)
[true, true, false, false]
```
