import from agents { CaseSpec }

obj DiffCfg {
    has name: str = "normal";
    has suspects: int = 4;
    has herrings: int = 1;
    has hint_cost: int = 100;
    has max_hints: int = -1;
    has wrong_allowed: int = 1;
    has multiplier: float = 1.0;
}

def difficulty_cfg(level: str) -> DiffCfg {
    if level == "easy" {
        return DiffCfg(name="easy", suspects=3, herrings=1, hint_cost=50, max_hints=-1, wrong_allowed=2, multiplier=0.8);
    }
    if level == "hard" {
        return DiffCfg(name="hard", suspects=5, herrings=2, hint_cost=150, max_hints=1, wrong_allowed=0, multiplier=1.5);
    }
    return DiffCfg(name="normal", suspects=4, herrings=1, hint_cost=100, max_hints=-1, wrong_allowed=1, multiplier=1.0);
}

def apply_score(score: int, event: str, hint_cost: int) -> int {
    change = 0;
    if event == "question" {
        change = -50;
    } elif event == "hint" {
        change = -hint_cost;
    } elif event == "crack" {
        change = 150;
    } elif event == "wrong_accuse" {
        change = -300;
    }
    return max(0, score + change);
}

def final_score(score: int, multiplier: float) -> int {
    return max(0, int(round(score * multiplier)));
}

def rank(score: int) -> str {
    if score >= 850 {
        return "Master Detective";
    } elif score >= 600 {
        return "Inspector";
    }
    return "Rookie";
}

# Returns a list of problems; an empty list means the case is playable.
def validate_case(spec: CaseSpec, cfg: DiffCfg) -> list[str] {
    problems: list[str] = [];
    sids = [s.id for s in spec.suspects];
    cids = [c.id for c in spec.clues];
    if len(spec.suspects) != cfg.suspects or len(set(sids)) != cfg.suspects {
        problems.append("wrong number of suspects");
        return problems;
    }
    if spec.culprit_id not in sids {
        problems.append("culprit is not a suspect");
        return problems;
    }
    if len(spec.clues) < 3 or len(spec.clues) > 7 or len(set(cids)) != len(cids) {
        problems.append("need 3-7 unique clues");
        return problems;
    }
    for c in spec.clues {
        if c.breaks is not None and c.breaks not in sids {
            problems.append(f"clue {c.id} breaks unknown suspect");
        }
        witnesses = [s.id for s in spec.suspects if c.id in s.knows];
        if len(witnesses) == 0 {
            problems.append(f"clue {c.id} is known by nobody");
        }
        if c.breaks is not None and c.breaks in witnesses {
            problems.append(f"clue {c.id} is known by the liar it breaks");
        }
        if c.breaks is not None and len([w for w in witnesses if w != c.breaks]) == 0 {
            problems.append(f"clue {c.id} has no witness");
        }
    }
    herrings = 0;
    for s in spec.suspects {
        for k in s.knows {
            if k not in cids {
                problems.append(f"{s.id} knows a missing clue");
            }
        }
        if s.lie is not None {
            breakers = [c for c in spec.clues if c.breaks == s.id];
            if len(breakers) == 0 {
                problems.append(f"liar {s.id} cannot be cracked");
            }
            if s.id != spec.culprit_id {
                herrings += 1;
            }
        } elif s.id == spec.culprit_id {
            problems.append("culprit has no lie");
        }
    }
    if herrings != cfg.herrings {
        problems.append("wrong number of red-herring liars");
    }
    return problems;
}
