# frozen_string_literal: true

class SyncTwitterAccountsJob < ApplicationJob
  queue_as :ingestion

  def perform
    TwitterAccount.find_each do |account|
      SyncSingleTwitterAccountJob.perform_later(account.id)
    end
  end
end
