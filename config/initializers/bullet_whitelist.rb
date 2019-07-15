# frozen_string_literal: true

if defined? Bullet
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Contact::Person', association: :tax_detail
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Contact::Organization', association: :tax_detail
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ContactDetail::Phone', association: :contact
  Bullet.add_whitelist type: :n_plus_one_query, class_name: 'ContactDetail::Email', association: :contact
end
