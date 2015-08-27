condition :presentation do
  (ENV['PRODUCT_VARIANT'] == 'presentation')
end

condition :swim do
  (ENV['PRODUCT_VARIANT'] == 'swim') or (not active? :presentation)
end

feature :persist_present_demo, :presentation
feature :delete_project_icon_via_button, false