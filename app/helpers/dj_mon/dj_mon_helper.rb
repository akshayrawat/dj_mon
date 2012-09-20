module DjMon::DjMonHelper
  def modal_dialog_template template_name, headline, &block
    render "dialog", :template_name => template_name, :headline => headline, :content => capture(&block)
  end
end
