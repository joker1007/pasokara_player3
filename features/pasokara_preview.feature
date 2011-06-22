# language: ja
フィーチャ: PasokaraFile preview
  ログイン後のユーザーは、PasokaraFileのプレビュー再生ができる

  シナリオ: プレビュー表示
    前提 登録済みユーザーが存在する
    前提 ユーザーID:"login"、パスワード:"password"でログインしている
    もし プレビューページを表示する
    ならば フラッシュプレーヤーが表示されていること
