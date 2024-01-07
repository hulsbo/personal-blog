require 'nokogiri'

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

# Save the modified table to a new file
File.open('modified_table.html', 'w') { |file| file.write(table.to_s) }
