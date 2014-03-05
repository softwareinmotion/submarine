condition :swim do
  (ENV['PRODUCT_VARIANT'] == 'swim')
end

condition :presentation do
  (ENV['PRODUCT_VARIANT'] == 'presentation') or (not active? :swim)
end

feature :persist_present_demo, :presentation
feature :delete_project_icon_via_button, false
