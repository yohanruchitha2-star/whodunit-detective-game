import from uuid { uuid4 }
import from game.graph { Case, Suspect, Clue, ChatLine, Knows, Breaks, Said }
import from game.shapes { SuspectSpec }
import from game.rules { apply_score, rank, filter_found_clues, breaks_lie, public_case }
import from game.backup_case { load_backup_case }

def _find_case(case_id: str) -> Case | None {
    for c in [root -->][?:Case] {
        if c.case_id == case_id {
            return c;
        }
    }
    return None;
}

def _find_suspect(case_node: Case, suspect_id: str) -> Suspect | None {
    for s in [case_node -->][?:Suspect] {
        if s.id == suspect_id {
            return s;
        }
    }
    return None;
}

def _find_clue(case_node: Case, clue_id: str) -> Clue | None {
    for c in [case_node -->][?:Clue] {
        if c.id == clue_id {
            return c;
        }
    }
    return None;
}

def _public_view_suspects(case_node: Case) -> list[SuspectSpec] {
    public_suspects: list[SuspectSpec] = [];
    for suspect in [case_node -->][?:Suspect] {
        public_suspects = public_suspects + [SuspectSpec(
            id=suspect.id,
            name=suspect.name,
            role=suspect.role,
            style=suspect.style,
            public_alibi=suspect.public_alibi,
            secret="",
            lie=None,
            knows=[]
        )];
    }
    return public_suspects;
}

def:pub new_case() -> dict[str, object] {
    spec = load_backup_case();
    new_id = str(uuid4());
    case_node = Case(
        case_id=new_id,
        title=spec.title,
        where=spec.where,
        what=spec.what,
        goal="Find who took it.",
        score=1000,
        wrong_guesses=0,
        game_over=False,
        culprit_id=spec.culprit_id,
        true_story=spec.true_story
    );
    root ++> case_node;

    for suspect_spec in spec.suspects {
        suspect = Suspect(
            id=suspect_spec.id,
            name=suspect_spec.name,
            role=suspect_spec.role,
            style=suspect_spec.style,
            public_alibi=suspect_spec.public_alibi,
            secret=suspect_spec.secret,
            lie=suspect_spec.lie or "",
            cracked=False
        );
        case_node ++> suspect;
    }
    for clue_spec in spec.clues {
        clue = Clue(
            id=clue_spec.id,
            title=clue_spec.title,
            text=clue_spec.text,
            found=False,
            used=False
        );
        case_node ++> clue;
        for suspect_spec in spec.suspects {
            if clue_spec.id in suspect_spec.knows {
                suspect_node = _find_suspect(case_node, suspect_spec.id);
                if suspect_node is not None {
                    suspect_node +>:Knows:+> clue;
                }
            }
        }
        if clue_spec.breaks is not None and clue_spec.breaks != "" {
            target_suspect = _find_suspect(case_node, clue_spec.breaks);
            if target_suspect is not None {
                clue +>:Breaks:+> target_suspect;
            }
        }
    }
    return public_case(
        new_id,
        case_node.title,
        case_node.where,
        case_node.what,
        case_node.goal,
        case_node.score,
        _public_view_suspects(case_node)
    );
}

def:pub question(case_id: str, suspect_id: str, text: str, clue_id: str | None = None) -> dict[str, object] {
    case_node = _find_case(case_id);
    if case_node is None {
        return {"error": "unknown_case"};
    }
    suspect = _find_suspect(case_node, suspect_id);
    if suspect is None {
        return {"error": "unknown_suspect"};
    }
    if case_node.game_over {
        return {"error": "game_over"};
    }

    reply = suspect.public_alibi;
    new_clues: list[dict[str, object]] = [];
    already_cracked = suspect.cracked;
    if clue_id is None {
        known_ids = [clue.id for clue in [suspect ->:Knows:->][?:Clue]];
        found_ids = [clue.id for clue in [suspect ->:Knows:->][?:Clue] if clue.found];
        proposed_ids = known_ids;
        revealed_ids = filter_found_clues(known_ids, found_ids, proposed_ids);
        for revealed_id in revealed_ids {
            clue = _find_clue(case_node, revealed_id);
            if clue is not None {
                clue.found = True;
                new_clues = new_clues + [{"id": clue.id, "title": clue.title, "text": clue.text}];
            }
        }
    } else {
        shown_clue = _find_clue(case_node, clue_id);
        if shown_clue is None or not shown_clue.found {
            return {"error": "clue_not_found_yet"};
        }
        has_break_edge = len([shown_clue ->:Breaks:->][?:Suspect, id == suspect_id]) > 0;
        cracked_now = breaks_lie(has_break_edge, shown_clue.found, suspect.cracked);
        if cracked_now {
            suspect.cracked = True;
            case_node.score = apply_score(case_node.score, "crack");
            reply = "Fine. I borrowed the key.";
        } else {
            reply = "That is not about me.";
        }
    }

    chat = ChatLine(who="player", text=text);
    suspect +>:Said:+> chat;
    case_node.score = apply_score(case_node.score, "question");
    return {
        "reply": reply,
        "new_clues": new_clues,
        "cracked": suspect.cracked,
        "already_cracked": already_cracked,
        "score": case_node.score
    };
}

def:pub hint(case_id: str) -> dict[str, object] {
    case_node = _find_case(case_id);
    if case_node is None {
        return {"error": "unknown_case"};
    }
    if case_node.game_over {
        return {"error": "game_over"};
    }
    case_node.score = apply_score(case_node.score, "hint");
    return {
        "hint": "Someone's alibi has a gap. Think about timing.",
        "score": case_node.score
    };
}

def:pub accuse(case_id: str, suspect_id: str, reason: str) -> dict[str, object] {
    case_node = _find_case(case_id);
    if case_node is None {
        return {"error": "unknown_case"};
    }
    suspect = _find_suspect(case_node, suspect_id);
    if suspect is None {
        return {"error": "unknown_suspect"};
    }
    if case_node.game_over {
        return {"error": "game_over"};
    }
    if suspect_id == case_node.culprit_id {
        case_node.game_over = True;
        return {
            "correct": True,
            "game_over": True,
            "score": case_node.score,
            "rank": rank(case_node.score),
            "culprit": {"id": suspect.id, "name": suspect.name},
            "story": case_node.true_story,
            "proof_clues": ["k1", "k3"]
        };
    }
    case_node.wrong_guesses += 1;
    case_node.score = apply_score(case_node.score, "wrong_accuse");
    if case_node.wrong_guesses >= 2 {
        case_node.game_over = True;
        culprit = _find_suspect(case_node, case_node.culprit_id);
        culprit_name = culprit.name if culprit is not None else "Unknown";
        return {
            "correct": False,
            "game_over": True,
            "score": case_node.score,
            "rank": rank(case_node.score),
            "culprit": {"id": case_node.culprit_id, "name": culprit_name},
            "story": case_node.true_story,
            "proof_clues": ["k1", "k3"]
        };
    }
    return {
        "correct": False,
        "game_over": False,
        "score": case_node.score,
        "chances_left": 1
    };
}
