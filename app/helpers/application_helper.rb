module ApplicationHelper
  def broadcast(channel, &block)
    message = {:channel => channel, :data => capture(&block)}
    uri = URI.parse("https://intense-meadow-95262.herokuapp.com/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def sortable(column, direction, title )
    link_to title, {:sort => column, :direction => direction}, {:class => 'sorttag'}
  end

  def sortable_search(column, direction, title )
    form_tag search_lessons_path, method: :get, id:"search_form" do
      concat hidden_field_tag :search, params[:search]
      concat hidden_field_tag :sort, column
      concat hidden_field_tag :direction, direction
      concat submit_tag title, class:"sorttag"
    end
  end

  JS_ESCAPE_MAP = {
    '\\'   => '\\\\',
    '<'    => '\\u003c',
    '&'    => '\\u0026',
    '>'    => '\\u003e',
    "\r\n" => '\n',
    "\n"   => '\n',
    "\r"   => '\n',
    '"'    => '\\u0022',
    "'"    => "\\u0027"
  }

  JS_ESCAPE_MAP["\342\200\250".force_encoding(Encoding::UTF_8).encode!] = '&#x2028;'
  JS_ESCAPE_MAP["\342\200\251".force_encoding(Encoding::UTF_8).encode!] = '&#x2029;'

  def escape_javascript_with_inside_html(javascript)
    if javascript
      result = javascript.gsub(/(\\|\r\n|\342\200\250|\342\200\251|[\n\r<>&"'])/u) {|match| JS_ESCAPE_MAP[match] }
      javascript.html_safe? ? result.html_safe : result
    else
      ''
    end
  end

  alias_method :jh, :escape_javascript_with_inside_html
end
