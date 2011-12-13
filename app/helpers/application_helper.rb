# coding: utf-8
module ApplicationHelper
  def entity_li(entity)
    content_tag(:li, :class => entity.class.to_s.underscore) do
      send(entity.class.to_s.underscore + "_li", entity)
    end
  end

  def directory_li(directory)
    image_tag("icon/elastic_movie.png", :size => "36x36", :class => "icon") +
    link_to(directory.name, directory)
  end

  def tag_li(tag_obj)
    image_tag("icon/search.png", :size => "36x36", :class => "icon") +
    link_to(tag_obj.value, search_pasokaras_path(:filter => tag_obj.value)) +
    "(#{tag_obj.count})"
  end
end
