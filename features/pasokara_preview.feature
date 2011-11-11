# language: ja
フィーチャ: PasokaraFile preview
  ログイン後のユーザーは、PasokaraFileのプレビュー再生ができる

  @selenium
  シナリオ: プレビュー表示
    前提 登録済みユーザーが存在する
    前提 登録済みのパソカラが存在する
    前提 webmエンコード済みのパソカラが存在する
    前提 ユーザーID:"login"、パスワード:"password"でログインしている
    もし プレビューページを表示する
    もし "2"秒待つ
    ならば videoタグが表示されていること
