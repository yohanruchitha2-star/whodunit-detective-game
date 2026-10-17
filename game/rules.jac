import from game.shapes { CaseSpec, SuspectSpec }

def apply_score(score: int, event: str) -> int {
    change = 0;
    if event == "question" {
        change = -50;
    } elif event == "hint" {
        change = -100;
    } elif event == "crack" {
        change = 150;
    } elif event == "wrong_accuse" {
        change = -300;
    }
    return max(0, score + change);
}

def rank(score: int) -> str {
    if score >= 850 {
        return "Master Detective";
    } elif score >= 600 {
        return "Inspector";
    }
    return "Rookie";
}

def validate_case(data: CaseSpec) -> bool {
    if len(data.suspects) != 4 {
        return False;
    }
    if len(data.clues) < 3 or len(data.clues) > 6 {
        return False;
    }

    suspect_ids: list[str] = [];
    culprit_count = 0;
    culprit_has_lie = False;
    culprit_has_breaking_clue = False;
    other_lie_with_break = False;
    for suspect in data.suspects {
        if suspect.id in suspect_ids {
            return False;
        }
        suspect_ids = suspect_ids + [suspect.id];
        if suspect.id == data.culprit_id {
            culprit_count += 1;
            culprit_has_lie = suspect.lie is not None and suspect.lie != "";
        }
    }
    if culprit_count != 1 {
        return False;
    }

    clue_ids: list[str] = [];
    for clue in data.clues {
        if clue.id in clue_ids {
            return False;
        }
        clue_ids = clue_ids + [clue.id];
        if clue.breaks is not None and clue.breaks != "" and clue.breaks not in suspect_ids {
            return False;
        }
        if clue.breaks == data.culprit_id {
            culprit_has_breaking_clue = True;
        }
        if clue.breaks is not None and clue.breaks != "" and clue.breaks != data.culprit_id {
            for suspect in data.suspects {
                if suspect.id == clue.breaks and suspect.lie is not None and suspect.lie != "" {
                    other_lie_with_break = True;
                }
            }
        }
    }
    if not culprit_has_lie or not culprit_has_breaking_clue or not other_lie_with_break {
        return False;
    }

    for suspect in data.suspects {
        for known_id in suspect.knows {
            if known_id not in clue_ids {
                return False;
            }
        }
    }
    for clue in data.clues {
        known_by_any = False;
        known_by_different_suspect = False;
        for suspect in data.suspects {
            if clue.id in suspect.knows {
                known_by_any = True;
                if clue.breaks is None or suspect.id != clue.breaks {
                    known_by_different_suspect = True;
                }
            }
        }
        if not known_by_any {
            return False;
        }
        if clue.breaks is not None and clue.breaks != "" and not known_by_different_suspect {
            return False;
        }
    }
    return True;
}

def filter_found_clues(known_ids: list[str], found_ids: list[str], proposed_ids: list[str]) -> list[str] {
    filtered: list[str] = [];
    for clue_id in proposed_ids {
        if clue_id in known_ids and clue_id not in found_ids and clue_id not in filtered {
            filtered = filtered + [clue_id];
        }
    }
    return filtered;
}

def breaks_lie(has_break_edge: bool, found: bool, cracked: bool) -> bool {
    return has_break_edge and found and not cracked;
}

def public_case(case_id: str, title: str, where: str, what: str, goal: str, score: int, suspects: list[SuspectSpec]) -> dict[str, object] {
    public_suspects: list[dict[str, object]] = [];
    for suspect in suspects {
        public_suspects = public_suspects + [{
            "id": suspect.id,
            "name": suspect.name,
            "role": suspect.role,
            "style": suspect.style
        }];
    }
    return {
        "case_id": case_id,
        "title": title,
        "where": where,
        "what": what,
        "goal": goal,
        "score": score,
        "suspects": public_suspects
    };
}
