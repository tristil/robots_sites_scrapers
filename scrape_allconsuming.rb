require 'rubygems'
require 'bundler/setup'
require 'capybara'
require 'erb'

# Lets you drop binding.pry in if you have an issue
require 'pry'
require 'pry-debugger'

Capybara.default_driver = :selenium
include Capybara::DSL

raise ArgumentError, "First argument (username) required" unless ARGV[0]
username = ARGV[0]
raise ArgumentError, "Second argument (username) required" unless ARGV[1]
password = ARGV[1]

visit('http://www.allconsuming.net/')
click_link('Login')

within '.login-form' do
  fill_in 'person[username]', with: username
  fill_in 'person[password]', with: password
  find("input[name='submit']").click
end

click_link 'Your Consumption'

lists = all('.box ul.last.clearfix li a').to_a +
  all('#recent-consumption a').to_a

data = lists.map do |list|
  { description: list.text, url: list[:href], list_items: [] }
end

data.each_with_index do |list, index|
  list_url = list[:url]
  visit list_url

  loop do
    urls = all('.personal-listed-items-list li strong a').map do |link|
      link[:href]
    end

    urls.each_with_index do |url, url_index|
      visit url
      description = find('.item-header-body').text
        .gsub('See this at Amazon.com', '')
        .gsub(/[^\x20-\x7E]/, '')
        .strip
      tags = find('#new-tags').text
      if tags !~ / \(x\)/
        tags = []
      else
        tags = tags.split(/ \(x\)/)
      end
      date_box = first('#buy div.interaction form')
      if date_box
        general_select = date_box.first("select[name='time_period']")
        if general_select
          date = general_select.value
        else
          year = date_box.first("select[name='date[year]']").value
          month = date_box.first("select[name='date[month]']").value
          day = date_box.first("select[name='date[day]']").value
          date = "#{month}/#{day}/#{year}"
        end
      else
        date = 'Still consuming'
      end
      data[index][:list_items] << { description: description,
                                    date: date,
                                    tags: tags }
    end

    visit list_url
    next_page = first(".pagination a[rel='next']")
    break unless next_page
    next_page.click
    list_url = page.current_url
  end
end

template = ERB.new(<<-HTML
<html>
  <body>
    <h1><%= username %> data dump from AllConsuming</h1>
    <% data.each do |list| %>
      <h2><%= list[:description] %></h2>
      <ol>
        <% list[:list_items].each do |list_item| %>
          <li>
            <ul>
              <li>Title: <%= list_item[:description] %></li>
              <li>Consumed on: <%= list_item[:date] %></li>
              <li>Tags: <%= list_item[:tags] %></li>
            </ul>
          </li>
        <% end %>
      </ol>
    <% end %>
  </body>
</html>
HTML
)

html = template.result

File.write('allconsuming.json', JSON.pretty_generate(data))
File.write('allconsuming.html', html)
