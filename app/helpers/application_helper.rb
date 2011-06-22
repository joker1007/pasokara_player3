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
    link_to(tag_obj.name, search_pasokaras_path(:filter => t.value)) +
    "(#{tag_obj.count})"
  end

  def embed_player(pasokara)
    raw("<embed id='player' name='player' src='/swfplayer/player-viral.swf' height='360' width='480' allowscriptaccess='always' allowfullscreen='true' flashvars='file=#{u pasokara.movie_path}&level=0&skin=%2Fswfplayer%2Fsnel.swf&image=#{u(pasokara.thumbnail.url)}&title=#{u pasokara.name}&autostart=true&dock=false&bandwidth=5000&plugins=viral-2d'/>")
  end
end
