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

end
