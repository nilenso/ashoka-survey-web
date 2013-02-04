class MultiRecordCategoryDecorator < CategoryDecorator
  decorates :multi_record_category

  def create_record_link(response_id)
    h.link_to I18n.t('responses.edit.create_record'),
              h.records_path(:record => { :category_id => model.id, :response_id => response_id  }),
              :method => :post
  end

  def category_name(answer, cache)
    # Don't show the multi-record title once per record. Only once total.
    if cache.select { |id, record_id| model.id == id }.present?
      model.category.decorate.category_name(answer, cache) if model.category
    else
      super
    end
  end
end