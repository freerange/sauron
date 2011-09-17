module ApplicationHelper
  def hiding_quoted_parts(string)
    if string
      lines = string.split("\n")
      quoted_lines = lines.select { |s| s =~ /^>/ }
      if quoted_lines == lines.slice(lines.length - quoted_lines.length, quoted_lines.length)
        lines = lines - quoted_lines
      end
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
end
