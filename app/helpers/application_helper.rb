module ApplicationHelper

  def nav_link(text, link)
    recognized = Rails.application.routes.recognize_path(link)
    if recognized[:controller] == params[:controller] && recognized[:action] == params[:action]
      content_tag(:li, :class => "active") do
        link_to( text, link)
      end
    else
      content_tag(:li) do
        link_to(text, link)
      end
    end
  end

  def flash_class(level)
    case level
      when :notice then "alert-info"
      when :error then "alert-danger"
      when :alert then ""
    end
  end

  def star_rating(val, classes="")
    val ||= 0
    multiplier = (classes =~ /mini-stars/) ? 10 : 16
    cls = "stars"
    cls << " #{classes}" if classes.present?
    size = [0, [5, val].min].max * multiplier
    content_tag(:span, class: cls) do
      content_tag(:span, "", style: "width: #{size}px;")
    end
  end

end
