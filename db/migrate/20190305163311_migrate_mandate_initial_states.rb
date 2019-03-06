class MigrateMandateInitialStates < ActiveRecord::Migration[5.2]
  def up
    Mandate.where(aasm_state: :prospect).update_all(aasm_state: :prospect_not_qualified)
  end

  def down
    Mandate.where(aasm_state: :prospect_not_qualified).update_all(aasm_state: :prospect)
  end
end
