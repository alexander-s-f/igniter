module IgniterPatientMedicalHistory

profile audited_medical_record
  time: bitemporal
  evidence: required

type MedicalEvent {
  valid_time: Timestamp          # when the event happened in reality
  transaction_time: Timestamp    # when we recorded it in the system
  patient_id: UUID
  event_type: :diagnosis | :medication | :surgery | :lab_result
  details: Map[String, Any]
  recorded_by: AuthorityRef
}

store PatientHistory : BiHistory[MedicalEvent]

contract ViewPatientRecordAsOf(patient_id: UUID, as_of: Timestamp)
  -> PatientSnapshot
{
  let snapshot = PatientHistory.query_as_of(as_of, patient_id)
  return PatientSnapshot {
    patient_id: patient_id,
    as_of: as_of,
    events: snapshot,
    current_diagnoses: snapshot.filter(e => e.event_type == :diagnosis && e.valid_time <= as_of)
  }
}

# ====================== WHAT THIS PROVES ======================
# Temporality is critically important in medicine: a doctor needs to see what they knew two months ago, not the current state.
# Correcting a diagnosis doesn't erase the old one—it creates a new version with an audit trail.