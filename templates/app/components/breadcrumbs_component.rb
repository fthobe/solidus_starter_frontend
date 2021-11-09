# frozen_string_literal: true

class BreadcrumbsComponent < ViewComponent::Base
  SEPARATOR = '&nbsp;&raquo;&nbsp;'.freeze
  BASE_CLASS = 'breadcrumbs'.freeze

  attr_reader :taxon

  def initialize(taxon)
    @taxon = taxon
  end

  def call
    breadcrumbs(taxon, "#{BASE_CLASS}__content")
  end

  private

  def breadcrumbs(taxon, breadcrumb_class = 'inline')
    return '' if current_page?('/') || taxon.nil?

    crumbs = [[t('spree.home'), helpers.spree.root_path]]

    crumbs << [t('spree.products'), helpers.spree.products_path]
    if taxon
      crumbs += taxon.ancestors.collect { |ancestor| [ancestor.name, helpers.spree.nested_taxons_path(ancestor.permalink)] }
      crumbs << [taxon.name, helpers.spree.nested_taxons_path(taxon.permalink)]
    end

    items = crumbs.each_with_index.collect do |crumb, index|
      content_tag(:li, itemprop: 'itemListElement', itemscope: '', itemtype: 'https://schema.org/ListItem') do
        link_to(crumb.last, itemprop: 'item') do
          content_tag(:span, crumb.first, itemprop: 'name') + tag('meta', { itemprop: 'position', content: (index + 1).to_s }, false, false)
        end + (crumb == crumbs.last ? '' : raw(SEPARATOR))
      end
    end

    content_tag(
      :div,
      content_tag(
        :nav,
        content_tag(
          :ol,
          raw(items.map(&:mb_chars).join),
          itemscope: '',
          itemtype: 'https://schema.org/BreadcrumbList'),
        class: breadcrumb_class
      ),
      class: BASE_CLASS
    )
  end
end
