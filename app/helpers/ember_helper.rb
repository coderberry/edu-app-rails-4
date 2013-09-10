module EmberHelper
  def js_env(env)
    if env.present?
      ret = "<script type=\"text/javascript\">ENV = {"
      env.each do |k, v|
        ret += "'#{k}':#{v.to_json},"
      end
      ret += "};</script>"
      ret
    end
  end
end
