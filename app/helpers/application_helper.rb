# coding: utf-8
module ApplicationHelper
  def entity_li(entity)
    content_tag(:li, :class => entity.class.to_s.underscore) do
      send(entity.class.to_s.underscore + "_li", entity)
    end
  end

  def directory_li(directory)
    image_tag("icon/elastic_movie.png", :size => "36x36", :class => "entity_icon") +
    link_to(directory.name, directory)
  end

  def tag_li(tag_obj)
    image_tag("icon/search.png", :size => "36x36", :class => "tag_icon") +
    link_to(tag_obj.name, root_path) +
    "(#{tag_obj.count})"
  end

  def pasokara_file_li(pasokara)
    #if current_user
      #title = link_to_remote(h(pasokara.name), :confirm => "#{pasokara.name}を予約に追加しますか？", :url => {:controller => 'pasokara', :action => 'queue', :id => pasokara.id}, :html => {:href => url_for(:controller => 'pasokara', :action => 'queue', :id => pasokara.id), :class => "queue_link"})
      #preview = link_to("[プレビュー]", pasokara.preview_path, :class => "preview_link", :target => "_blank")
    #else 
      #title = content_tag(:span, h(pasokara.name), :class => "title")
      #preview = content_tag(:span, "[プレビュー]", :class => "preview")
    #end
    title = link_to(pasokara.name, queue_pasokara_path(pasokara), :remote => true, :confirm => "#{pasokara.name}を予約に追加しますか？", :class => "queue_link")
    preview = link_to("[プレビュー]", pasokara.preview_path, :class => "preview_link", :target => "_blank")

    content_tag(:div, :class => "title") do
      image_tag("icon/music_48x48.png", :size => @icon_size, :class => "entity_icon") +
      title + 
      preview + 
      link_to("[関連動画を探す]", root_path, :class => "related_search_link", :target => "_blank") +
      content_tag(:span, :class => "duration") {pasokara.duration_str} +
      link_to(image_tag("icon/star_off_48.png", :size => "24x24"), root_path, :remote => true, :confirm => "#{pasokara.name}をお気に入りに追加しますか？", :class => "add_favorite")
    end +
    info_box(pasokara)
  end

  def info_box(entity)
    %Q{
      <div id="info-box-#{entity.id}" class="info_box">
        <h3>タグ</h3>
        #{tag_list(entity)}
        <hr />
        <h3>動画情報</h3>
        #{info_list(entity)}
      </div>
    }
  end

  def info_list(entity)
    %Q{
      <div id="info-list-#{entity.id}" class="info_list">
        <div class="thumb clearfix">#{image_tag(thumb_pasokara_path(entity.id), :size => "160x120", :class => "thumb")}</div>
        <div class="nico_info clearfix">
          <span class="info_key">ニコニコID:</span><span class="info_value">#{link_to(entity.nico_name, entity.nico_url) if entity.nico_name}</span><br />
          <span class="info_key">投稿日:</span><span class="info_value">#{h entity.nico_post_str}</span><br />
          <span class="info_key">再生数:</span><span class="info_value">#{number_with_delimiter(entity.nico_view_counter)}</span><br />
          <span class="info_key">コメント数:</span><span class="info_value">#{number_with_delimiter(entity.nico_comment_num)}</span><br />
          <span class="info_key">マイリスト数:</span><span class="info_value">#{number_with_delimiter(entity.nico_mylist_counter)}</span><br />
        </div>
      </div>
    }
  end

  def tag_list(entity)
    content_tag("div", {:id => "tag-list-#{entity.id}", :class => "tag_list"}) do
      entity.tag_list.inject("") do |str, p_tag|
        str << content_tag("span", {:class => "tag"}) do
          "<a href=\"/tag_search/#{u p_tag}\">#{h p_tag}</a>"
        end
        str
      end
      #link_to_remote("[編集]", :url => tag_form_open_path(:id => entity), :html => {:href => tag_form_open_path(:id => entity), :class => "tag_edit_link"})
    end
  end

  def navi_bar
    str = %Q{
      <ul id="menu">
        <li>#{link_to("ホーム", {:controller => 'dir', :action => 'index'}, :id => "home")}</li>
        <li>#{link_to("予約確認", {:controller => 'queue', :action => 'list'}, :id => "queue")}</li>
        <li>#{link_to("りれき", {:controller => 'sing_log', :action => 'list'}, :id => "history")}</li>
    }
    #if current_user
      #str += %Q{
        #<li>#{link_to("お気に入り", {:controller => 'favorite', :action => 'list'}, :id => "favorite")}</li>
        #<li>#{link_to("設定変更", edit_user_path(current_user.id), :id => "user_edit")}</li>
      #}
    #end
    str += %Q{
        <li>#{link_to("使い方", {:controller => 'help', :action => 'usage'}, :id => "usage")}</li>
      </ul>
    }
    str
  end

end
