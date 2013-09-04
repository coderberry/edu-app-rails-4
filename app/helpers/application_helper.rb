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

  def status_label(status)
    classes = ['label']
    case status
    when 'pending'
      classes << 'label-primary'
    when 'active'
      classes << 'label-success'
    when 'disabled'
      classes << 'label-default'
    end
    content_tag(:span, status.upcase, class: classes.join(' '))
  end

  def icon(icon_url)
    icon = icon_url
    if icon_url.blank?
      icon = asset_path('blank_icon.png')
    end
    image_tag(icon, class: "icon", width: 16, height: 16)
  end

  def status_badge(status)
    status_map = { pending: 'info', active: 'success', disabled: 'default' }
    "<span class=\"label label-#{status_map[status.to_sym]}\">#{status.capitalize}</span>"
  end

end
