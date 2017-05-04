# タグメール

#### 目次

1. [モジュールの説明 - モジュールの機能とその有益性](#説明)
2. [セットアップ - タグメール導入の基本](#セットアップ)
  * [要件](#要件)
  * [タグメールの使用を始める](#タグメールの使用を始める)
3. [使用 - 設定オプションと追加機能](#使用)
4. [制約 - OS互換性など](#制約)
5. [開発 - モジュール貢献についてのガイド](#開発)


## 説明

タグメールモジュールは、ログメッセージが指定のタグを割り当てられたリソースに関連する場合に、EメールとしてPuppetログメッセージを送信するものです。このモジュールの機能は、過去にPuppetに内蔵されていたタグメール機能と同じです。

タグメールモジュールは、特定のタグと特定のEメールアドレスをペアリングし、ログメッセージをEメールレポートに分類できる[レポートプロセッサ](https://docs.puppetlabs.com/guides/reporting.html)プラグインです。このモジュールは、Puppet内蔵のタグメール機能の代わりになるものです。内蔵機能は、JVMベースのPE 3.7でブレークされ、PE 3.8およびPuppet 4.0で完全に削除されました。

> タグメールモジュールのバージョン1.xがサポートしているのは、Puppet 3.7～3.8およびPE 3.7～3.8.1のみである点に注意してください。それよりも新しいバージョンのPuppetおよびPEについては、タグメール2.0にアップグレードする必要があります。それよりも古いバージョンのPuppetの場合は、Puppet内蔵のタグメール機能を使用してください。

## セットアップ

### 要件

このモジュールは、Puppet EnterpriseおよびPuppetバージョン3.8以降をサポートしています。それよりも古いバージョンのPuppetの場合は、Puppet内蔵のタグメール機能を使用してください。

### タグメールの使用を始める

1. 各Puppet agent上で、[`pluginsync`](https://docs.puppet.com/latest/configuration.html#pluginsync)および[`report`](https://docs.puppet.com/latest/configuration.html#report)設定が有効になっていることを確認します(これらの設定は通常、デフォルトで有効になっています)。

  ```
[agent]
report = true
pluginsync = true
  ```

2. Puppet master上で、master画面の[`reports`](https://docs.puppetlabs.com/references/4.2.latest/configuration.html#reports)設定にタグメールを含めます。

  ```
[master]
tagmap = $confdir/tagmail.conf
reports = puppetdb,console,tagmail
  ```

3. メールサーバー上でグレイリストなどのアンチスパムコントロールを使用している場合は、Puppetの送信するEメールアドレスをホワイトリストに入れ、タグメールレポートがスパムとして破棄されないようにします。この設定は、`puppet.conf`の`reportfrom`設定でコントロールできます。

4. masterのPuppet confdirで、`tagmail.conf`ファイルを作成します。このファイルに、Eメール送信設定オプションとタグそのものが含まれます。

## 使用

### タグ

タグを使えば、リソース、クラス、定義タイプのコンテキストを設定できます。たとえば、特定のオペレーティングシステムやロケーションなどの特性に関連するすべてのリソースに、1つのタグを割り当てることができます。これにより、そのタグが、当該リソースに関連するすべてのログメッセージに含まれます。

Puppetの[ログレベル](https://docs.puppet.com/latest/metaparameter.html#loglevel) (`debug`、`info`、`notice`、`warning`、`err`、`alert`、`emerg`、`crit`、`verbose`)も、タグとして使うことが可能です。`all`タグは、常にすべてのログメッセージにマッチします。タグの詳細については、Puppet Languageドキュメントの[タグ](http://docs.puppetlabs.com/puppet/latest/reference/lang_tags.html)を参照してください。

### `tagmail.conf`の設定

タグメールモジュールを設定するには、上述のステップ4で作成した`tagmail.conf`ファイルを編集します。このファイルは、Puppet confdirにあります。`tagmail.conf`は、iniファイルとしてフォーマットする必要があります。

1. テキストエディタで`tagmail.conf`を開き、`[transport]`および`[tagmap]`セクションを追加します。

1. `[transport]`セクションで、以下のいずれかを指定します:

   * `sendmail`、sendmailバイナリのパス(デフォルトでは、`/usr/sbin/sendmail`)。
   * `smtpserver`、`smtpport`、`smtphelo`。`smtpserver`を指定しない場合、タグメールのデフォルト設定で`sendmail`を使用します。

1. `[tagmap]`セクションで、タグとEメールアドレスを指定します。各行に以下の両方を含める必要があります:

   * タグのカンマ区切りリスト、コロンで終わるもの。
   * リストにあるタグのログメッセージを受信するEメールアドレスのカンマ区切りリスト。オプションとして、タグの最初にエクスクラメーションマークを付ければ、任意のタグを除外することができます。

たとえば、以下の`tagmail.conf`では、すべてのログメッセージが`me@example.com`に送信され、メールサーバー*ではない*ウェブサーバーから送られるすべてのメッセージが`httpadmins@example.com`および`you@example.com`に送信されます。

```
[transport]
reportfrom = reports@example.org
smtpserver = smtp.example.org
smtpport = 25
smtphelo = example.org

[tagmap]
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
```

`smtpserver`の代わりに`sendmail`を指定すると、以下のようになります。

```
[transport]
reportfrom = reports@example.org
sendmail = /usr/sbin/sendmail

[tagmap]
all: me@example.com
webserver, !mailserver: httpadmins@example.com, you@example.com
```

## 制約

このモジュールは、Puppet EnterpriseおよびPuppetバージョン3.8以降のみをサポートし、Puppet master上でJVMを使用している場合のみ使用できます。それよりも古いバージョンのPuppetや、Apache/Rack/Passenger上で古いPuppet masterを使用している場合は、Puppet内蔵のタグメール機能を使用してください。

## 開発

Puppet ForgeのPuppet Labsモジュールはオープンプロジェクトで、良い状態に保つためには、コミュニティの貢献が必要不可欠です。Puppetが役に立つはずでありながら、私たちがアクセスできないプラットフォームやハードウェア、ソフトウェア、デプロイ構成は無数にあります。私たちの目標は、できる限り簡単に変更に貢献し、みなさまの環境で私たちのモジュールが機能できるようにすることにあります。最高の状態を維持できるようにするために、コントリビュータが従う必要のあるいくつかのガイドラインが存在します。

詳細については、[モジュールコントリビューションガイド](https://docs.puppet.com/forge/contributing.html)を参照してください。

すでに参加している人を見るには、[コントリビュータのリスト](https://github.com/puppetlabs/puppetlabs-tagmail/graphs/contributors)を参照してください。