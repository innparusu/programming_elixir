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

# 第6章 モジュールと名前付き関数
- Elixir の名前付き関数はモジュール内部でかく必要がある
- 下のコードは``Times``という名前のモジュールをつくり, その中に ``double`` という関数を作っている
    - 関数の名前は``double/1`` となる
``` elixir 
defmodule Times do
  def double(n) do
    n * 2 
  end
end
```

## 6.1 モジュールのコンパイル
- ファイルをコンパイルし, iex へロードする方法は2つある
    - 一つ目は ``$ iex times.exs`` とする
    - すでにiex にいるなら cヘルパーでコンパイルするとコマンドラインに戻る必要はない
- 同じ名前で引数が別の関数は何らかの関係がある(無くてもそう思ってしまう)ので、関係ない2角関数に同じ名前を付けない

## 6.2 関数のボディはブロックだ
- ``do ... end`` ブロックは複数の式をグループ化し、他のコードに渡す方法の1つ
- しかし, ``do ... end`` は基本的な構文ではない, 実際は ``def double(n), do: n * 2``な構文
- これは括弧でグループ化することで, `` do: `` に複数行渡すことが出来る

``` elixir
def greet(greeting, name), do: (
  IO.puts greeting
  IO.puts "How're you doing, #{name}?"
)
```

- ``do ... end`` 形式は、ただのシンタックスシュガー で、コンパイル時に do: 形式に変換される
    - ``do:``  形式は単なるキーワードリストの一単語
- 主に１行ブロックの時には ``do:`` 形式, 複数行に渡るときは `` do ..end`` を使う
- つまりtimes は以下の様にかける

``` elixir
defmodule Times do
  def double(n), do: n * 2
end
```

## 6.3 関数呼び出しとパターンマッチ
- 名前付き関数もパターンマッチを行うことが出来る
- 無名関数の時との違いとして毎回パラメータとボディも書く必要がある(Haskell とかと同じ)
- 名前つき関数を呼び出すときまずはじめの定義(節)のパラメータリストにマッチさせようとする, もしマッチしなかったら同じ関数の次の定義を試す(同じ関数では引数の数が同じでなければならない)
- 以下にn! の定義を示す

``` elixir
defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n-1)
end
```

- Elixir は 以下のように2番目が呼ばれることのない関数は警告を出す

``` elixir
defmodule Factorial do
  def of(n), do: n * of(n-1)
  def of(0), do: 1
end
```

## 6.4 ガード節
- 型や値の評価のチェックによって区別したいときはカード節を使う
- カード節は１つ以上の ``when`` キーワードを使って、関数定義にくっつける記述
- Elixir は従来のパラメータベースのマッチングを行い, それから ``when`` 述語を全て評価し、少なくとも１つの記述が真であるとき関数を実行する

``` elixir
defmodule Guard do
  def what_is(x) when is_number(x) do
    IO.puts "#{x} is a number"
  end
  def what_is(x) when is_list(x) do
    IO.puts "#{inspect(x)} is a list"
  end
  def what_is(x) when is_atom(x) do
    IO.puts "#{x} is an atom"
  end
end
```

- 階乗の例(p47)だと負の数を渡すと, 無限に繰り返してしまう, それに対処するためにガード節を追加する
- ガード節には Elixir の一部の式しか書くことが出来ない(p51)

## 6.5 デフォルトパラメータ
- 名前付き関数を定義するとき ``(パラメータ) \\ (値)`` という構文で, どのパラメータにもデフォルトの値を設定する事ができる
- 渡された引数の数が必須パラメータより多い場合, その分だけ分だけデフォルトの値を上書きする, パラメータは左から右へとマッチする

``` elixir
defmodule Example do
  def func(p1, p2 \\ 2, p3 \\ 3, p4) do
    IO.inspect [p1, p2, p3, p4]
  end
end

Example.func("a","b") # => ["a", 2, 3, "b"]
Example.func("a","b", "c") # => ["a", "b", 3, "c"]
Example.func("a","b", "c", "d") # => ["a", "b", "c", "d"]
```

- デフォルトパラメータを使用すると以下のコードはエラーとなる
- これは最初の関数定義は2~4つの引数の呼び出しのどれでもマッチするため

``` elixir
defmodule Example do
  def func(p1, p2 \\ 2, p3 \\ 3, p4) do
    IO.inspect [p1, p2, p3, p4]
  end
  def func(p1, p2) do
    IO.inspect [p1, p2, p3, p4]
  end
end
```

```
Erlang/OTP 19 [erts-8.0.2] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

** (CompileError) mm/default_params.exs:5: def func/2 conflicts with defaults from def func/4
```

- 複数のヘッドをもつ関数の中の１つがデフォルトパラメータをもつ場合エラーを吐く(1.3.2 だとwarning)
- これはデフォルトパラメータが引き起こす混乱を減らそうという意図

``` elixir
defmodule DefaultParams1 do
  def func(p1, p2 \\ 123) do
    IO.inspect [p1, p2]
  end

  def func(p1, 99) do
    IO.puts "you said 99"
  end
end
```

``` elixir
defmodule DefaultParams1 do
  def func(p1, p2 \\ 99) do
    IO.inspect [p1, p2]
  end

  def func(p1, 99) do
    IO.puts "you said 99"
  end
end

DefaultParams1.func(1, 99) #=> [1,99]
```

- この場合, デフォルトパラメータを含む関数のヘッドだけを、ボディなしで追加して, 後の関数定義では通常のパラメータを使う
    - すべてのこの関数呼び出しでデフォルト値が適用される

``` elixir
defmodule Params do
  def func(p1, p2 \\ 123)
  
  def func(p1, p2) when is_list(p1) do
    "You said #{p2} with a list"
  end

  def func(p1, p2) do
    "You said #{p1} and #{p2}"
  end
end
```

## 6.6 プライベート関数
- ``defp`` マクロはプライベート関数を定義する
- プライベート関数はそれが宣言されたモジュール内でしか呼び出せない
- ``def`` と同様に複数のヘッドをもつプライベート関数を定義することが出来る
- あるヘッドはプライベート, 他はパプリックには出来ない

``` elixir
# このコードは無理
def fun(a) when is_list(a), do: true
def fun(a), do: false
```

## 6.7 素晴らしきパイプ演算子
-  ``|> `` を使用して関数呼び出しを綺麗に書く

``` elixir
people = DB.find_customers
orders = Orders.for_customers(people)
tax    = sales_tax(orders, 2016)
filing = prepare_filing(tax)

# ↑はこうもかける(でもこれを見るのは辛い)
filing = prepare_filing(sales_tax(Order.for_customer(DB.find_customers), 2016))
```

- ``|>`` 演算子は左の項の式の結果をとって, 右の関数呼び出しの第一引数として渡す
- つまり, 最初の呼び出しで得られる顧客のリストは ``for_customers`` の第一引数になる, その結果の注文リストは ``sales_tax`` の第一引数になり2016は第二引数になる

``` elixir
filing = DB.find_customers
           |> Orders.for_customers
           |> sales_tax(2016)
           |> prepare_filing
```

- `` val |> f(a,b)`` は基本的には ``f(val, a, b)`` と同じ
- ``|>`` は同じ行につなげてかける
    - 関数のパラメーターには括弧を付ける必要がある(大事なことなので2回書いてる)

``` elixir
iex(1)> (1..10) |> Enum.map(&(&1*&1)) |> Enum.filter(&(&1<40))
[1, 4, 9, 16, 25, 36]
```

- プログラミングはデータの変換であり, ``|>`` はこの変換の様子をはっきりと見せてくれる

## 6.8 モジュール
- モジュールは定義するものにネームスペースを提供する
- モジュールの外から何かを取り出すときはモジュール名を前につける
- 入れ子モジュールもできる
    - 入れ子のモジュール内にアクセスするには全てのモジュールの名前を前に書く
- Elixir にとって入れ子モジュールはただのまやかし
    - 全てのモジュールはトップレベルで定義される
    - あるモジュールを他のモジュールの内側に定義すると, Elixir は外側のモジュールの名前を内側のモジュールの名前にドットを間に挟んでくっつける
    - つまり, 入れ子になったモジュールは直接定義することが出来る(これは外側のモジュールと 外側のモジュール.内側のモジュールに特別なつながりがないということを示す)

``` elixir
defmodule Mix.Tasks.Doctest do
  def run do
  end
end
```

### モジュールのディレクティブ
- Elixir にはモジュールの取り扱いをかんたんにする3つのディレクティブがある
- 3つとも全てプログラムが走る際に実行されるものであり, 3津の影響全てレキシカルスコープ
    - つまり, モジュール内でディレクティブを書いた所からモジュールの終わりまで影響を与える

### import ディレクティブ
- import ディレクティブはモジュールの関数やマクロをcurrentスコープに持ってくる
- 特定のモジュールをコード内で何度も使うのであればimport ディレクティブを使うとソースファイルの散らかり具合をマシにしてくれる(モジュール名を繰り返し書くを防げるから)

``` elixir
defmodule Example do
  def func1 do
    List.flatten [1,[2,3],4]
  end
  def func2 do
    import List, only: [flatten: 1]
    flatten [5,[6,7],8]
  end
end
```

- import の完全な構文は ``import Module [, only:|except:]`` となる
- 省略可能な2番目のパラメータはどの関数やマクロを取り組むかを指定できる
    - ``only:, expect:`` に ``name: arity(パラメータの数)``のペアを続けて書く
- ``only:`` に ``:function`` か ``:macros`` というアトムを与えることで関数化マクロだけを取り組むことが出来る

### alias ディレクティブ
- alias ディレクティブはモジュールのエイリアスを作る
- 分かりやすい使い方としてはタイピング量をえらすために使える

``` elixir
defmodule Example do
  def compile_and_go(source) do
    alias My.Other.Module.Parser, as: Parser
    alias My.Other.Module.Runner, as: Runner
    source
    |> Parser.parse()
    |> Runner.execute()
  end
end
```

- この alias ディレクティブの省略形として次のように書くことが出来る
- なぜなら, ``as:``パラメータはモジュール名の最後の部分をデフォルト値とするため

``` elixir
alias My.Other.Module.Parser, as: Parser
alias My.Other.Module.Runner, as: Runner
```

- こんな風にもかける

``` elixir
alias My.Other.Module.{Parser, Runner}
```

### require ディレクティブ
- モジュールで定義したマクロを使うにはそのモジュールをrequire する
- コードをコンパイルするときにマクロ定義が有効になっていることを証明する


## 6.9 モジュールの属性
- Elixir モジュールはそれぞれ対応するmetadataを持っている
- metadataの各項目のことをモジュールの属性といい, 名前によって識別される
- モジュールの内部では ``@`` 記号を名前の前につけて、属性にアクセスすることが出来る
- ``@name value`` で属性に値を与えることが出来る
    - これはモジュールのトップレベルでしか出来ない(関数定義の中では属性をセットは出来ない, アクセスは可能)

``` elixir
defmodule Example do
  @author "Dave Thomas"
  def get_author do
    @author
  end
end

IO.puts "Example was written by #{Example.get_author}"
```

- モジュールでは同じ属性に何度も値を設定することが出来る
- 名前付き関数でそのモジュールの属性にアクセスすると, その値は関数が定義された時に有効な値になる

``` elixir
defmodule Example do
  @attr "one"
  def first, do: @attr
  @attr "two"
  def second, do: @attr
end

IO.puts "#{Example.first} #{Example.second}" #=> one two
```

- 属性は従来の感覚で言うところの変数ではない, 設定、あるいはmetadataとして使うもの(多くのElixir プログラマは Javaや Ruby では定数を使うようなところで使ってる)

## 6.10 モジュールの名前 : Elixir, Erlang, そしてアトム
- モジュールの名前は内部的にはただのアトムに過ぎない
- IO といった,大文字から始まる名前を書いた時, Elixir は内部で ``Elixir.IO`` というアトムに変換する

``` elixir
iex(1)> is_atom IO
true
iex(2)> to_string IO
"Elixir.IO"
iex(3)> :"Elixir.IO" === IO
true
```

- つまり, モジュール内の関数呼び出しは実際にはアトムにドット, 関数名をつなげて行われる

``` elixir
iex(5)> IO.puts 123
123
:ok
iex(6)> :"Elixir.IO".puts 123
123
:ok
```

## 6.11 Erlang のライブラリにある関数の呼び出し
- Erlang の命名規則は Elixir とは異なり, 変数は大文字から始まり, アトムは単純な小文字
- そのため Erlang の ``timer`` モジュールはそのまま, ``timer`` というアトムで呼ばれる
    - Elixir はこれを``:timer`` とかく, tc関数の呼び出しは ``:timer.tc`` とかく
    - つまり, Erlang のライブラリで呼び出したいものがあれば, ``:モジュール名.関数`` で呼び出せる

``` elixir
iex(10)> :io.format("The number is ~3.1f~n",[5.678])
The number is 5.7
:ok
```

## 6.12 ライブラリを見つける
- アプリで使うライブラリを探すのなら, まずは Elixir の既存のモジュールを探すと良い
- 組み込みライブラリは Elixir のドキュメントに、その他は hex.pm や Github にある
- もし望んでいるものがないならErlangの組み込みライブラリを探すか, Erlang ドキュメントをWeb で検索する

## 練習問題:ModulesAndFunctions-7
- 環境変数を取り出す -> System.get_env
- ファイル名の拡張子 -> Path.extname

# 7章 リストと再帰
- 問題を正しいやり方で扱うなら, 再帰はリストを処理するのに完璧なツール

## 7.1 ヘッドとテイル
- リストはからでなければヘッドとテイルによって構成される

## 7.6 より複雑なリストのパターン
- 連結演算子``|``はその左辺に複数の値を置くことが出来る

``` elixir
iex(4)> [1,2,3 | [4,5,6]]
[1, 2, 3, 4, 5, 6]
iex(5)>
```

- パターンでも同じことができる

``` elixir
# リスト内の値のペアをスワップする
defmodule Swapper do
  def swap([]), do: []
  def swap([a,b | tail]), do: [b, a | swap(tail)]
  def swap([_]), do: raise "Can't swap a list with an odd number of elements"
end
```

- Elixir のパターンマッチは再帰的で, パターンの中で, パターンをマッチさせることが出来る

``` elixir
defmodule WeatherHistory do
  def for_location([], _target_loc), do: []
  def for_location([ head = [_, target_loc, _, _] | tail], target_loc) do # この行は head というパラメータにlistをマッチさせている
    [ head | for_location(tail, target_loc) ]
  end
  def for_location([ _ | tail], target_loc), do: for_location(tail, target_loc)
end
```

## 7.7 実践 List モジュール
- List モジュールはリストを操作する関数のセットを提供する
- List.flatten : 平滑化
- List.foldl : 畳込み(左)
- List.foldr : 畳込み(右)
- List.replace_at : 中の要素を置き換える
- List.keyfind:キーワードリストにアクセスする
- List.keydelete:キーワードリストにアクセスする
- List.keyreplace:キーワードリストにアクセスする

# 8章 map, キーワードリスト, セット, 構造体

## 8.1 mapとキーワードリスト, どちらを使うべきか
- キーワードリストを使う
    - 同じキーをもつものが2回以上現れる
    - 順序を保証する
- map
    - 内容についてパターンマッチを行いたい
    - 上記のキーワードリストの利点以外の場合

## 8.2 キーワードリスト
- キーワードリストは主に、関数に渡されるオプションの用途で使われる
- アクセス演算子(``list[key]``), ``Keyword``, ``Enum``モジュールの全ての関数が利用可能

``` elixir
defmodule Canvas do

  @defaults [ fg: "black", bg: "white", font: "Merriweather" ]

  def draw_text(text, options \\ []) do
    options = Keyword.merge(@defaults, options)
    IO.puts "Drawing text #{inspect(text)}"
    IO.puts "Foreground: #{options[:fg]}"
    IO.puts "Background: #{Keyword.get(options, :bg)}"
    IO.puts "Font: #{Keyword.get(options, :font)}"
    IO.puts "Pattern: #{Keyword.get(options, :pattern, "solid")}"
    IO.puts "Style: #{inspect Keyword.get_values(options, :style)}"
  end
end

Canvas.draw_text("hello", fg: "red", style: "italic", style: "bold")
```

## 8.3 マップ
- マップはどんなサイズでも良い性能を出すことが出来る

``` elixir
iex(1)> map = %{ name: "Dave", likes: "Programming", where: "Dalias" }
%{likes: "Programming", name: "Dave", where: "Dalias"}
iex(2)> map
%{likes: "Programming", name: "Dave", where: "Dalias"}
iex(3)> Map.keys map
[:likes, :name, :where]
iex(4)> Map.values map
["Programming", "Dave", "Dalias"]
iex(5)> map[:name]
"Dave"
iex(6)> map.name
"Dave"
iex(7)> map1 = Map.drop map, [:where, :likes]
%{name: "Dave"}
iex(8)> map2 = Map.put map, :also_likes, "Ruby"
%{also_likes: "Ruby", likes: "Programming", name: "Dave", where: "Dalias"}
iex(9)> Map.keys map2
[:also_likes, :likes, :name, :where]
iex(10)> Map.has_key? map1, :where
false
iex(11)> { value, updated_map } = Map.pop map2, :also_likes
{"Ruby", %{likes: "Programming", name: "Dave", where: "Dalias"}}
iex(12)> Map.equal? map, updated_map
true
```

## 8.4 マップのパターンマッチ
- マップに対する一番よくある問い合わせは 「これらのキー(値)を持っているか?」

``` elixir
iex(13)> person = %{ name: "Dave", height: 1.88 }
%{height: 1.88, name: "Dave"}

# :name をキーとしたエントリがあるか?
iex(14)> %{ name: a_name } = person
%{height: 1.88, name: "Dave"}
iex(15)> a_name
"Dave"

# :name, :height をキーとするエントリがあるか?
iex(16)> %{ name: _, height: _ } = person
%{height: 1.88, name: "Dave"}

# :name は "Dave"か?
iex(17)> %{ name: "Dave" } = person
%{height: 1.88, name: "Dave"}

# :weight はないので, 次のパターンマッチは失敗
iex(18)> %{ name: _, weight: _ } = person
** (MatchError) no match of right hand side value: %{height: 1.88, name: "Dave"}
```

- マップの構造を分解し, あるキーに関連付けられた値を取り出すやり方はいろいろな用途に使える
- for を使ってコレクションの各要素を繰り返すことが出来る(詳しくは内包表現でやる(p103)
- 下のコードではマップのリストから, それぞれのマップを取り出し, person に束縛し, 変数 height にマップの高さを束縛している

``` elixir
people = [
  %{ name: "Grumpy",     height: 1.24 },
  %{ name: "Dave",       height: 1.88 },
  %{ name: "Dopey",      height: 1.32 },
  %{ name: "Shaquille",  height: 2.16 },
  %{ name: "Sheezy",     height: 1.28 },
]

IO.inspect(for person = %{ height: height } <- people, height > 1.5, do: person)
```

- パターンマッチはただのパターンマッチなので、マップのこの機能は cond式, 関数のヘッドのマッチ, そしてパターンマッチが使われるどんな状況でも同じように動作する

``` elixir
defmodule HotelRoom do

  def book(%{name: name, height: height})
  when height > 1.9 do
    IO.puts "Need extra long bed for #{name}"
  end

  def book(%{name: name, height: height})
  when height < 1.3 do
    IO.puts "Need low shower controls for #{name}"
  end

  def book(person) do
    IO.puts "Need regular bed for #{person.name}"
  end

end

people = [
  %{ name: "Grumpy",     height: 1.24 },
  %{ name: "Dave",       height: 1.88 },
  %{ name: "Dopey",      height: 1.32 },
  %{ name: "Shaquille",  height: 2.16 },
  %{ name: "Sheezy",     height: 1.28 },
]
people |> Enum.each(&HotelRoom.book/1)
```

### パターンマッチはキーを束縛できない
- パターンマッチはキーに値を束縛することが出来ない

``` elixir 
iex(1)> %{ 2 => state } = %{ 1 => :ok, 2 => :error }
%{1 => :ok, 2 => :error}
iex(2)> state
:error
iex(3)> %{ item => :ok } = %{ 1 => :ok, 2 => :error }
** (CompileError) iex:3: illegal use of variable item inside map key match, maps can only match on existing variable by using ^item
    (stdlib) lists.erl:1354: :lists.mapfoldl/3
```

### 変数キーにマッチするパターンマッチ
- ピン演算子はマップのキーでも使用できる

``` elixir
iex(3)> for key <- [ :name, :likes ] do
...(3)>  %{ ^key => value } = data
...(3)>  value
...(3)> end
["Dave", "Elixir"]
```

## 8.5 マップの更新
- マップを更新する最も簡単な方法は ``new_map = %{ old_map | key => value, ...}``
    - パイプ文字の右にあるキーに関連付けられた値は更新される

``` elixir
iex(5)> m = %{ a: 1, b: 2, c: 3}
%{a: 1, b: 2, c: 3}
iex(6)> m1 = %{ m | b: "two", c: "three"}
%{a: 1, b: "two", c: "three"}
iex(7)> m1 = %{ m1 | a: "one" }
%{a: "one", b: "two", c: "three"}
```

- 上記の方法では新しいキーはマップに追加されない, ``Map.put_new/3`` を使う
    - ``Map.put/3`` との違いとして, 既にキーがある場合 ``Map.put_new/3``は更新されない

## 8.6 構造体
- 構造体は制限された形式のマップをラップしたモジュール
    - キーはアトムである必要があり, Map 機能の一部を持っていないという制限
- モジュールの名前が構造体の型の名前になる
    - モジュールの中で構造体を定義するには ``defstruct`` マクロを使う

``` elixir
defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end
```

- 構造体を作るための構文はマップを作る構文と同じ
- 構造体のフィールドにアクセスするにはドット記法か、パターンマッチを使う
- 更新方法もマップと同じ

``` elixir
iex(1)> s1 = %Subscriber{}
%Subscriber{name: "", over_18: true, paid: false}
iex(2)> %Subscriber{ name: "Dave" }
%Subscriber{name: "Dave", over_18: true, paid: false}
iex(3)> s2 = %Subscriber{ name: "Dave" }
%Subscriber{name: "Dave", over_18: true, paid: false}
iex(4)> s3 = %Subscriber{ name: "Mary", paid: true }
%Subscriber{name: "Mary", over_18: true, paid: true}
iex(5)> s3.name
"Mary"
iex(6)> %Subscriber{name: a_name} = s3
%Subscriber{name: "Mary", over_18: true, paid: true}
iex(7)> a_name
"Mary"
iex(8)> s4 = %Subscriber{ s3 | name: "Marie" }
%Subscriber{name: "Marie", over_18: true, paid: true}
```

- 構造体独自の挙動を追加したくなるため, 構造体はモジュールにラップされている

``` elixir
defmodule Attendee do
  defstruct name: "", paid: false, over_18: true

  def may_attend_affter_party(attendee = %Attendee{}) do
    attendee.paid && attendee.over_18
  end

  def print_vip_badge(%Attendee{name: name}) when name != "" do
    IO.puts "Very cheap badge for #{name}"
  end

  def print_vip_badge(%Attendee{}) do
    raise "missing naem for badge"
  end
end
```

``` elixir
iex(4)> a1 = %Attendee{ name: "Dave", over_18: true }
%Attendee{name: "Dave", over_18: true, paid: false}
iex(5)> Attendee.may_attend_affter_party(a1
...(5)> )
false
iex(6)> a2 = %Attendee{a1 | paid: true}
%Attendee{name: "Dave", over_18: true, paid: true}
iex(7)> Attendee.may_attend_affter_party(a2)
true
iex(8)> Attendee.print_vip_badge(a2)
Very cheap badge for Dave
:ok
iex(9)> a3 = %Attendee{}
%Attendee{name: "", over_18: true, paid: false}
iex(10)> Attendee.print_vip_badge(a3)
** (RuntimeError) missing naem for badge
    maps/defstruct1.exs:13: Attendee.print_vip_badge/1
```

- 構造体はポリモーフィズムを実装する際にも重要な役割を果たす

## 8.7 入れ子になった辞書構造体
- 通常ドット記法で入れ子のフィールドにアクセスできる
- しかしデータを更新する際には読みにくくなる(入れ子になった辞書の外も更新しなければならない)

```elixir
iex(1)> report = %BugReport{ owner: %Customer{name: "Dave", company: "Pragmatic"}, details: "broken"}
%BugReport{details: "broken",
 owner: %Customer{company: "Pragmatic", name: "Dave"}, severity: 1}
iex(2)> report.owner.company
"Pragmatic"
iex(3)> report = %BugReport{ report | owner: %Customer{ report.owner | company: "PragProg"}}
%BugReport{details: "broken",
 owner: %Customer{company: "PragProg", name: "Dave"}, severity: 1}
```

- ``put_in``というマクロを使うと入れ子構造の中に値をセットすることが出来る

``` elixir
iex(4)> put_in(report.owner.company, "PragProg")
%BugReport{details: "broken",
 owner: %Customer{company: "PragProg", name: "Dave"}, severity: 1}
```

- ``update_in`` 関数は構造体の中の値に関数を適用してくれる

``` elixir
iex(5)> update_in(report.owner.name, &("Mr. " <> & 1))
%BugReport{details: "broken",
 owner: %Customer{company: "PragProg", name: "Mr. Dave"}, severity: 1}
```

- 他にも ``get_in``, ``get_and_update_in`` という２つの関数がある

### 入れ子accessorと非構造体
- マップやキーワードリストで入れ子アクセサを使うときはキーをアトムで書くことが出来る

``` elixir
iex(6)> report = %{ owner: %{ name: "Dave", company: "Pragmatic" }, severity: 1}
%{owner: %{company: "Pragmatic", name: "Dave"}, severity: 1}
iex(7)> put_in(report[:owner][:company], "PragProg")
%{owner: %{company: "PragProg", name: "Dave"}, severity: 1}
iex(8)> update_in(report[:owner][:name], &("Mr. " <> &1))
%{owner: %{company: "Pragmatic", name: "Mr. Dave"}, severity: 1}
iex(9)> "hoge"<>"huga"
```

### 動的な(ランタイムの) 入れ子accessor
- ここまで見てきた入れ子accessorは結局のところマクロ
    - コンパイル時に作用するもの
- そのためいくつかの制限がある
    - 個々に呼び出しに渡すキーの数は変更しない
    - 関数間でキーの集合をパラメータとして渡すことが出来ない
- この制限を乗り越えるために``get_in``, ``put_in``, ``update_in``, ``get_and_update_in`` はキーのリストを独立したパラメータとして取ることが出来る そうすることでマクロから関数呼び出しに代わり, 動的になる

``` elixir
nested = %{
  buttercup: %{
    actor: %{
      first: "Robin",
      last: "Wright"
    },
    role: "princess"
  },
  westley: %{
    actor: %{
      first: "Carey",
      last: "Ewes" #typo!
    },
    role: "farm boy"
  }
}

IO.inspect get_in(nested, [:buttercup])
#=> %{actor: %{first: "Robin", last: "Wright"}, role: "princess"}

IO.inspect get_in(nested, [:buttercup, :actor])
#=> %{first: "Robin", last: "Wright"}

IO.inspect put_in(nested, [:westley, :actor, :last], "Elwes")
#=> %{buttercup: %{actor: %{first: "Robin", last: "Wright"}, role: "princess"},
#=>  westley: %{actor: %{first: "Carey", last: "Elwes"}, role: "farm boy"}}
```

- ``get_in`` と ``get_and_update_in`` の動的バージョンがサポートするトリックがある
    - 関数をキーとして渡すと関数が起動されて、対応する値を返す

``` elixir
authors = [
  %{ name: "Jose", language: "Elixir"},
  %{ name: "Matz", language: "Ruby"},
  %{ name: "Larry", language: "Perf"}
]

language_with_an_r = fn (:get, collection, next_fn) ->
  for row <- collection do
    if String.contains?(row.language, "r") do
      next_fn.(row)
    end
  end
end

IO.inspect get_in(authors, [language_with_an_r, :name])
```

## 8.8 セット
- 今のところ, セットの実装は ``MapSet`` 1つ

``` elixir
iex(16)> set1 = Enum.into 1..5, MapSet. new
#MapSet<[1, 2, 3, 4, 5]>
iex(17)> MapSet.member? set1, 3
true
iex(18)> set2 = Enum.into 3..8, MapSet.new
#MapSet<[3, 4, 5, 6, 7, 8]>
iex(19)> MapSet.union set1, set2
#MapSet<[1, 2, 3, 4, 5, 6, 7, 8]>
iex(20)> MapSet.difference set1, set2
#MapSet<[1, 2]>
iex(21)> MapSet.difference set2, set1
#MapSet<[6, 7, 8]>
iex(22)> MapSet.intersection set1, set2
#MapSet<[3, 4, 5]>
```

# 9章 寄り道:型とは何か？
- Elixir のプリミティブデータ型はそれが表現出来る方と同じである必要はない
    - Elixir のプリミティブなリストは単に値が順に並んでいるグループにすぎない ``[..]``リテラルを使ってリストを作る事ができ, ``|``演算子でリストの分解と構築ができる
- もう一つのレイヤーとして Elixir には List モジュールがある, これはリストを操作する関数を提供している
- リストプリミティブとListモジュールの提供する機能性は違うもの
    - リストプリミティブは実装
    - List モジュールは抽象化のレイヤーを追加する
- 上記のものはどちらも型を実装しているが違う種類のもの
    - リストプリミティブは flatten 関数を持っていない
- マップもプリミティブ型
- ``keyword``型は タプルのリストで実装されているElixir のモジュール

``` elixir
options = [ {:width, 72}, {:style, "light"}, {:style, "print"} ]
```

- これはリストのためリストのための関数は動作する. さらに Elixir は辞書らしい挙動をするための機能も追加している

``` elixir
iex(1)> options = [ {:width, 72}, {:style, "light"}, {:style, "print"} ]
[width: 72, style: "light", style: "print"]
iex(2)> List.last options
{:style, "print"}
iex(3)> Keyword.get_values options, :style
["light", "print"]
```

- 見方によってはダックタイミングの形
- Keyword モジュールは土台となる Keyword プリミティブデータ型を持っていない. このモジュールで扱う値はどれもある方法で構造化されたリストということを単純に仮定しているだけ
- つまり, Elixir のコレクション API はかなり幅広い

# 10章 コレクションの処理 Eunm と Stream
