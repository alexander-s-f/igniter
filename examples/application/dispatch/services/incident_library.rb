# frozen_string_literal: true

require "json"

require_relative "runbook_parser"

module Dispatch
  module Services
    class IncidentLibrary
      attr_reader :root

      def initialize(root:)
        @root = File.expand_path(root)
      end

      def default_incident_id
        "INC-001"
      end

      def find_incident(id)
        incidents.find { |incident| incident.fetch(:id) == id.to_s }
      end

      def team?(id)
        teams.any? { |team| team.fetch(:id) == id.to_s }
      end

      def bundle(incident_id)
        incident = find_incident(incident_id)
        return nil unless incident

        {
          incident: incident,
          events: fetch_events(incident.fetch(:event_ids)),
          runbooks: runbooks.select { |runbook| runbook.fetch(:service) == incident.fetch(:service) },
          teams: teams
        }.freeze
      end

      private

      def incidents
        @incidents ||= load_json_files(File.join(root, "incidents", "*.json"))
      end

      def events
        @events ||= load_json_files(File.join(root, "events", "*.json"))
      end

      def runbooks
        @runbooks ||= Dir.glob(File.join(root, "runbooks", "*.md")).sort.map do |path|
          Services::RunbookParser.parse(path)
        end.freeze
      end

      def teams
        @teams ||= JSON.parse(File.read(File.join(root, "teams.json")), symbolize_names: true).map(&:freeze).freeze
      end

      def load_json_files(pattern)
        Dir.glob(pattern).sort.map do |path|
          JSON.parse(File.read(path), symbolize_names: true).merge(source_path: path).freeze
        end.freeze
      end

      def fetch_events(ids)
        ids.map do |id|
          events.find { |event| event.fetch(:id) == id }
        end.compact.freeze
      end
    end
  end
end
