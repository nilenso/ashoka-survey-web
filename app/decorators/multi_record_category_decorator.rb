class MultiRecordCategoryDecorator < Draper::Base
  decorates :multi_record_category

  def create_record_link(response_id)
    h.link_to I18n.t('responses.edit.create_record'),
              h.records_path(:record => { :category_id => model.id, :response_id => response_id  }),
              :method => :post
  end
end