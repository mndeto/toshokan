Then /^I should see a journal with table of contents$/ do
  page.should have_css '#document.blacklight-journal .toc'
  page.should have_css '.toc .toc_issues'
  page.should have_css '.toc .toc_articles'
end

Then /^I should see at least (\d+) years of issues$/ do |n|
  all('.toc_year').should have_at_least(n).items
end

Then /^I should see the first issue as selected$/ do
  first_issue = find('.toc_issue')
  first_issue.tag_name.should_not eq 'a'
end

Then /^I should see the second issue as selected$/ do
  first_issue = find('.toc_issue')
  first_issue.tag_name.should eq 'a'
  second_issue = first_issue.find(:xpath, './../following-sibling::*/*')
  second_issue.tag_name.should_not eq 'a'
end

Then /^I should see the list of articles in the issue$/ do
  find('.toc_articles').should have_css('.toc_article')
end