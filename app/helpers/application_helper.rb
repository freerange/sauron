module ApplicationHelper
  def ul(objects, options = {})
    if objects.any?
      content_tag('ul', options) do
        objects.each do |object|
          yield(object)
        end
      end
    else
      content_tag(:p, options[:empty_list])
    end
  end
end
