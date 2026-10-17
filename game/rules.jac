import from game.types { CaseSpec, PublicCase, Result }

# TODO: validate a proposed case specification.
def validate_case(spec: CaseSpec) -> bool {
    return False;
}

# TODO: apply an authorized score event.
def score_event(event: str) -> int {
    return 0;
}

# TODO: mark a suspect cracked after the walker checks the rules.
def mark_cracked(suspect_id: str) -> bool {
    return False;
}

# TODO: project graph state into a safe public case.
def to_public(case_id: str) -> PublicCase {
    return PublicCase();
}
