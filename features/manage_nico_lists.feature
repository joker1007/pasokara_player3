# language: ja
フィーチャ: Manage nico_lists
  ログイン後のユーザーは、ダウンロードリスト情報が参照できる
  ログイン後のユーザーは、ダウンロードリスト情報を作成できる
  ログイン後のユーザーは、ダウンロードリスト情報を編集・削除できる
  ログイン後のユーザーにAdmin権限が無い場合はダウンロードリストを参照できない
  ログインしていない場合は、ダウンロードリストは操作できない

  シナリオ: ログイン要求 1
    もし "the nico lists page"ページを表示する
    ならば "ログイン"ページを表示していること
  シナリオ: ログイン要求 2
    もし ダウンロードリスト編集ページを表示する
    ならば "ログイン"ページを表示していること
  シナリオ: ログイン要求 3
    もし "the new nico list page"ページを表示する
    ならば "ログイン"ページを表示していること

  シナリオ: ダウンロードリスト一覧表示
    前提 登録済みのダウンロードリストが存在する
    前提 登録済みユーザーが存在する
    前提 ユーザーID:"login"、パスワード:"password"でログインしている
    もし "the nico lists page"ページを表示する
    ならば ダウンロードリストの一覧が表示されていること

  シナリオ: ダウンロードリスト一覧表示(Admin権限無し)
    前提 登録済みのダウンロードリストが存在する
    前提 登録済みユーザー2が存在する
    前提 ユーザーID:"login2"、パスワード:"password"でログインしている
    もし "the nico lists page"ページを表示する
    ならば "トップ"ページを表示していること

  シナリオ: ダウンロードリスト編集ページ表示
    前提 登録済みユーザーが存在する
    前提 ユーザーID:"login"、パスワード:"password"でログインしている
    もし ダウンロードリスト編集ページを表示する
    ならば 入力項目"Url"に"http://www.test.com/test"と表示されていること
    ならば "Download"がチェックされていること

  シナリオ: ダウンロードリスト一覧表示
    前提 登録済みユーザーが存在する
    前提 ユーザーID:"login"、パスワード:"password"でログインしている
    前提 "the new nico list page"ページを表示している
    もし "Url"に"http://www.test2.com/"と入力する
    もし "Download"をチェックする
    もし "Save"ボタンをクリックする
    ならば /追加されました/と表示されていること
