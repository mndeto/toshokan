# encoding: utf-8
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # Should we display the pagination controls?
  #
  # @param [Blacklight::SolrResponse]
  # @return [Boolean]
  def show_pagination? response = nil
    response ||= @response
    response.limit_value > 0 && response.total_pages > 1
  end

  # Extends default behavior to inject .homegrown class if content is from "local" source
  def render_document_class(document = @document)
    document_classes = super(document) ? [super(document)] : []
    if homegrown_content?(document)
      document_classes << "homegrown"
    end
    return document_classes.join(' ')
  end

  # Returns true if the document is from a "local" source
  def homegrown_content?(document = @document)
    (document['source_ss'] || []).any? { |s| ['orbit','sorbit'].include? s }
  end

  # Called from DTU override of render_facet_item
  # Return true for the access type that corresponds
  # to the current user.
  def display_online_access_value?(field_value)
    field_value == current_user.access_type ? true : false
  end

  # If we're getting this far the user should have access
  def online_access_facet_display(value)
    'Yes'
  end

  # Only show the facet box if there is content for the current user
  def show_online_access_facet?(_field_config, facets)
    facets.items.map(&:value).include? current_user.access_type
  end
end
