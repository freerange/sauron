module ApplicationHelper
  def hiding_quoted_parts(string)
    if string
      lines = string.split("\n").map { |s| s.strip }
      quoted_lines = lines.select { |s| s =~ /^>/ }
      if quoted_lines.any? && quoted_lines == lines.slice(lines.index(quoted_lines.first), quoted_lines.length)
        lines = lines - quoted_lines
        lines.pop while lines.last == ""
        if lines.last.strip =~ /^\s*On .* wrote:\s*$/
          lines.pop
        end
      end
      lines.pop while lines.last == ""
      lines.join("<br/>").html_safe
    end
  end

  def said
    %w(said wrote quoth spake penned scrieved scribbled uttered).sample
  end

  def display_name(contact)
    if contact.name
      contact.name.gsub(/\s+/, "&nbsp;").html_safe
    else
      contact.email
    end
  end

  def metadata_for(part)
    part["headers"]["Content-Type"].split(";").first
  end
end
