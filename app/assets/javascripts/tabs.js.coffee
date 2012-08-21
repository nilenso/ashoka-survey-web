SurveyApp.tabify = (tabsContainer) ->
  tabsContainer.find('.tabs li').click(@switch_tabs) 

SurveyApp.switch_tabs = (event) ->
  clicked_tab = $(event.target)
  sidebar_div = clicked_tab.parent().parent()

  sidebar_div.find('li').removeClass('active')
  clicked_tab.addClass('active')

  sidebar_div.children('div').hide()
  clicked_tab_target = sidebar_div.find(clicked_tab.data('tab-target'))
  clicked_tab_target.show()
