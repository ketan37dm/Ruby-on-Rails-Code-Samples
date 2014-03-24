module BootstrapFlashHelper
  def bootstrap_flash
   flash_messages = []
   flash.each do |type, message|
     type = :success  if type == :notice or type == :success
     type = :success  if type == :alert or type == :error
     text = content_tag(:div, link_to("x", "#", :class => "close", "data-dismiss" => "alert") + message, :class => "error-margin alert fade in alert-#{type}", style: "text-align: center;" )
     flash_messages << text if message
   end
   flash_messages.join("\n").html_safe
 end
end
