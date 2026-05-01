# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :Article do
      persist key: :id, adapter: :sqlite

      field :id
      field :title, type: :string
      field :body, type: :string
      field :created_at, type: :datetime
      field :status, type: :enum, values: %i[draft published archived], default: :draft

      index :status
      scope :drafts, where: { status: :draft }
      scope :published, where: { status: :published }
      command :publish, operation: :record_update, changes: { status: :published }
      relation :comments_by_article, kind: :event_owner, to: :comments, join: { id: :article_id }, cardinality: :one_to_many
    end
  end
end
