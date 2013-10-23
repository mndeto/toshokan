Then /^I should see "(.*?)"$/ do |content|
  page.should have_content content
end

Then /^I should(?: not|n't) see "(.*?)"$/ do |content|
  page.should_not have_content content
end

Then /^I should(n't| not)? see the search page$/ do |negate|
  page.has_css?('#search').should (negate ? be_false : be_true)
end

Then /^I should(n't| not)? see the "(.*?)" link$/ do |negate, expected|
  found = false
  # Test all links
  page.body.scan /<a .*?>(.*?)<\/a>/ do |link, _|
    # Trim spaces, normalize spaces, remove markup
    actual = link.gsub(/^\s+|<.*?>|\s+$/, '').gsub(/\s+/, ' ')
    found ||= actual == expected
  end
  found.should (negate ? be_false : be_true)
end

Then /^render the page$/ do
  page.driver.render('/tmp/render.png', :full => true)
end

Then /^render the page as (.*)$/ do |name|
  page.driver.render("/tmp/#{name}.png", :full => true)
end

Then /^show me the page$/ do 
  save_and_open_page 
end

When /^I reload the page$/ do
  visit(current_path)
end

When /^I click "(.*?)"$/ do |name|
  click_link_or_button name
end

When /^I click the link "(.*?)"$/ do |link|
  click_link link
end

When /^I go to the root page$/ do
  visit root_path
end

Then /^I should be redirected to DTU CAS$/ do
  response.should redirect_to new_user_session_path
end

