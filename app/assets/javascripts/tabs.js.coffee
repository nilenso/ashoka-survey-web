SurveyApp.tabify = (tabsContainer) ->
  tabsContainer.find('.tabs li').click(@switch_tabs) 

SurveyApp.switch_tabs = (event) ->
  clicked_tab = $(event.target)
  container = clicked_tab.parent().parent()

  all_tabs = container.find('li')
  all_tabs.removeClass('active')

  clicked_tab.addClass('active')

  all_panes = container.children('div')
  all_panes.hide()

  target_pane = container.find(clicked_tab.data('tab-target'))
  target_pane.show()
