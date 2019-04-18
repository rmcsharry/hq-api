class NormalizePhoneFaxNumbers < ActiveRecord::Migration[5.2]
  def up
    ContactDetail::Phone.find_each do |phone|
      phone.value = PhonyRails.normalize_number(phone.value)
      phone.save!
    end
    ContactDetail::Fax.find_each do |fax|
      fax.value = PhonyRails.normalize_number(fax.value)
      fax.save!
    end
  end
end
