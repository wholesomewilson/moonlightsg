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
end
