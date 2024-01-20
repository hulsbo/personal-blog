require 'nokogiri'

# Remove old modified_table.html
if File.exist?("modified_table.html")
    File.delete("modified_table.html")
    puts "#{'modified_table.html'} has been deleted. Generating new one..."
  else
    puts "File does not exist. Generating new one..."
  end

# Load the HTML content from the file
html_content = File.read('Sheet2.html')
doc = Nokogiri::HTML(html_content)

# Extract the first <table> element
table = doc.at_css('table')

# Remove all <th> elements from the table
table.css('th').each(&:remove)

# Remove all <tr> elements within <thead>
table.css('thead tr').each(&:remove)

# Move the first two <tr> elements from <tbody> to <thead>
tbody = table.at_css('tbody')
thead = table.at_css('thead')

# Select the first two <tr> elements from <tbody>
tr_elements = tbody.css('tr')[0, 2]
tr_elements.each do |tr|
  tr.remove # Remove from <tbody>
  thead.add_child(tr)    # Add to <thead>
end

# Helper function to merge empty tds by setting colspan on the preceding td
def merge_empty_tds(prev_td, empty_tds)
  return if empty_tds.empty? || prev_td.nil?

  # Set colspan on the preceding non-empty td
  colspan = empty_tds.length + 1
  prev_td.set_attribute('colspan', colspan.to_s)

  # Remove the empty tds
  empty_tds.each(&:remove)
end

# Process each row in the table
doc.css('tr').each do |row|

    # Check if this row has any td with a child div having class 'softmerge-inner'
    next unless row.css('td div').any? { |div| div.content.include?('|') }

    prev_td = nil
    empty_tds = []

  row.css('td').each do |td|
    # Check if the td is empty
    if td.content.strip.empty?
      empty_tds << td
    else
      # Process accumulated empty tds
      merge_empty_tds(prev_td, empty_tds)
      empty_tds = []
      prev_td = td
    end
  end

  # Check at the end of the row
  merge_empty_tds(prev_td, empty_tds)
end

    # ADDING LIQUID TO LAST TD
doc.css('tr').each do |row|
    # Extract the date from the first td
    date = row.at_css('td')&.content&.strip

    # Find the last td in the row
    last_td = row.at_css('td:last-child')

    # Check if the last td is empty and insert the Liquid code
    if last_td.content.strip.empty?
      liquid_code = "\n{% assign currentDate = '#{date}' %}\n" +
                    "{% for entry in site.data.log %}\n" +
                    "  {% if entry.date == currentDate %}\n" +
                    "      {% if entry.content %}\n" +
                    "        <p>{{ entry.content }}</p>\n" +
                    "      {% endif %}\n" +
                    "      {% if entry.distance %}\n" +
                    "        <p>Total distance: {{ entry.distance }}</p>\n" +
                    "      {% endif %}\n" +
                    "      {% if entry.ahr %}\n" +
                    "        <p>Average HR: {{ entry.ahr }}</p>\n" +
                    "      {% endif %}\n" +
                    "      {% if entry.highlight %}\n" +
                    "        <p>Workout highlight: {{ entry.highlight }}</p>\n" +
                    "      {% endif %}\n" +
                    "{% endif %}\n" +
                    "{% endfor %}\n" +
                    "{% assign foundPost = nil %}\n" +
                    "      {% for post in site.posts %}\n" +
                    "           {% assign postDate = post.date | date: '%Y-%m-%d' %}\n" +
                    "            {% if postDate == currentDate %}\n" +
                    "               {% assign foundPost = post %}\n" + # foundPost is always the earliest post.date inside _posts
                    "            {% endif %}\n" +
                    "        {% endfor %}\n" +
                    "      {% if foundPost %}\n" +
                    "        <p><a href='{{ foundPost.url }}'>Read today's post: {{ foundPost.title }}</a></p>\n" +
                    "        <p>{{ foundPost.date | date: '%Y-%m-%d' }}<p>" +
                    "      {% endif %}\n"


      last_td.inner_html = liquid_code
    end
  end

    # Adding styling to headers
    doc.css('tr').each do |row|
    # Check if any td in this row contains "Weekday" or "phase"
    if row.css('td').any? { |td| td.content.match?(/\b(Weekday|phase)\b/i) }
      # Apply inline bold styling to all td elements in this row
      row.css('td').each do |td|
        td.inner_html = "<strong>#{td.inner_html}</strong>"
      end
    end
  end

    # ADDING CLASS ATTRIBUTES
    ## ADDING WEEKDAY
    # Select all <tr> elements
    doc.xpath('//tr').each do |tr|
        # Within each <tr>, find the second <td>
        first_td = tr.xpath('td[1]')
        second_td = tr.xpath('td[2]')
        third_td = tr.xpath('td[3]')
        forth_td = tr.xpath('td[4]')
        fifth_td = tr.xpath('td[5]')

        # Replace the class attribute with 'weekday' for the second <td>
        first_td.first.set_attribute('class', 'date') unless first_td.empty?
        second_td.first.set_attribute('class', 'wday') unless second_td.empty?
        third_td.first.set_attribute('class', 'type') unless third_td.empty?
        forth_td.first.set_attribute('class', 'dura') unless forth_td.empty?
        fifth_td.first.set_attribute('class', 'note') unless fifth_td.empty?
  end

# Save the modified table to a new file
File.open('modified_table.html', 'w') { |file| file.write(table.to_s) }
