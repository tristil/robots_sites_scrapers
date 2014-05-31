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

visit('http://www.listsofbests.com/')
click_link('Login')

within '.login-form' do
  fill_in 'person[username]', with: username
  fill_in 'person[password]', with: password
  find("input[name='submit']").click
end

find('a', text: /Your (\d+) Lists/).click

lists = nil

within '.list-of-lists' do
  lists = all('li a')
end

data = lists.map do |list|
  { description: list.text, url: list[:href], list_items: [] }
end

data.each_with_index do |list, index|
  visit list[:url]

  loop do
    begin
      within '#sortable_list' do
        all('li').each do |li|
          data[index][:list_items] << li.text.gsub(/\A\d+\. (\? )?/, '')
        end
      end
    rescue Capybara::ElementNotFound
      break
    end

    next_pages = []
    within '#items' do
      next_pages = all("a[rel='next']")
    end
    binding.pry if next_pages.length > 2
    break unless next_pages.any?
    next_pages.first.click
  end
end

template = ERB.new(<<-HTML
<html>
  <body>
    <h1><%= username %> data dump from Lists Of Bests</h1>
    <% data.each do |list| %>
      <h2><%= list[:description] %></h2>
      <ol>
        <% list[:list_items].each do |list_item| %>
          <li><%= list_item %></li>
        <% end %>
      </ol>
    <% end %>
  </body>
</html>
HTML
)

html = template.result

File.write('listofbests.json', JSON.pretty_generate(data))
File.write('listofbests.html', html)
