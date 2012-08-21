describe "Tabs", ->
  beforeEach ->
    loadFixtures 'tabs'
    SurveyApp.tabify($('.sidebar'))

  it "switches to the clicked tab", ->
    tab = $('.tabs').find('li').first()
    tab.click()
    target = $(tab.data('tab-target'))
    expect(target).not.toBeHidden()

  it "hides all tabs except the clicked one", ->
    tab = $('.tabs').find('li').first()
    tab.click()
    other_tab = $('.tabs').find('li').last()
    other_target = $(other_tab.data('tab-target'))
    expect(other_target).toBeHidden()

  it "activates the clicked tab", ->
    tab = $('.tabs').find('li').first()
    tab.click()
    expect(tab).toHaveClass('active')

  it "deactivates all tabs except the clicked one", ->
    tab = $('.tabs').find('li').first()
    tab.click()
    other_tab = $('.tabs').find('li').last()
    other_tab.click()
    expect(tab).not.toHaveClass('active')