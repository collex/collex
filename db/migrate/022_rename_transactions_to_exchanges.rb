class RenameTransactionsToExchanges < ActiveRecord::Migration
  def self.up
  	rename_table :transactions, :exchanges
  end

  def self.down
  	rename_table :exchanges, :transactions
  end
end
